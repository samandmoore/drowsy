require 'active_support/notifications'
require 'faraday'

class Drowsy::Http
  def initialize(connection)
    @connection = connection
  end

  %i(get post put patch delete).each do |method|
    define_method(method) do |*args|
      request(method, *args)
    end
  end

  def request(method, path, params: nil, headers: nil, options: nil)
    ActiveSupport::Notifications.instrument('request.drowsy', method: method) do |payload|
      payload[:method] = method
      payload[:service] = connection.url_prefix.to_s
      payload[:path] = path

      begin
        response = connection.send(method) do |request|
          request.headers.merge!(headers) if headers
          apply_options(request, options) if options

          if method == :get
            request.url path, params
          else
            request.url path
            request.body = params
          end
        end

        payload[:status] = response.status

        Result.new handle_response(response)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError => e
        raise Drowsy::ConnectionError, e
      end
    end
  end

  def inspect
    "#<Drowsy::Http(#{connection.url_prefix})>"
  end

  private

  attr_reader :connection

  def apply_options(request, options)
    timeout = options.delete(:timeout)
    open_timeout = options.delete(:open_timeout)
    raise "options not implemented: #{options.keys.join(', ')}" unless options.empty?
    request.options[:timeout] = timeout if timeout
    request.options[:open_timeout] = open_timeout if open_timeout
  end

  def handle_response(response)
    case response.status
    when 200...400
      response
    when 401
      raise Drowsy::UnauthorizedError, response
    when 403
      raise Drowsy::ForbiddenError, response
    when 404
      raise Drowsy::ResourceNotFound, response
    when 422
      raise Drowsy::ResourceInvalid, response
    when 401...500
      raise Drowsy::ClientError, response
    when 500...600
      raise Drowsy::ServerError, response
    else
      raise Drowsy::UnknownResponseError, response
    end
  end

  class Result
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def data
      response.body[:data]
    end

    def errors
      response.body[:errors]
    end
  end
end
