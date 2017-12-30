class Sleepy::Http
  def initialize(connection)
    @connection = connection
  end

  %w(get post put patch delete).each do |method|
    define_method(method) do |*args|
      request(method, *args)
    end
  end

  def request(method, path, params = nil, headers: nil, options: nil)
    ActiveSupport::Notifications.instrument('request.sleepy', method: method) do |payload|
      payload[:method] = method
      payload[:url] = connection.url_prefix.to_s + path

      begin
        response = connection.send(method) do |request|
          request.headers.merge!(headers) if headers
          apply_options(request, options) if options

          if method == :get
            request.url path.to_s, params
          else
            request.url path.to_s
            request.body = params
          end
        end

        payload[:status] = response.status

        handle_response(response)
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::SSLError => e
        payload[:connection_error] = true
        raise Sleepy::ConnectionError, e
      end
    end
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
      raise Sleepy::UnauthorizedError, response
    when 403
      raise Sleepy::ForbiddenError, response
    when 404
      raise Sleepy::ResourceNotFound, response
    when 422
      raise Sleepy::ResourceInvalid, response
    when 401...500
      raise Sleepy::ClientError, response
    when 500...600
      raise Sleepy::ServerError, response
    else
      raise Sleepy::UnknownResponseError, response
    end
  end
end
