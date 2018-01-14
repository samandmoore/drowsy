require 'drowsy/uri'
require 'drowsy/http'

class Drowsy::HttpRequest
  def initialize(connection, method, uri_template, params)
    @connection = connection
    @method = method
    @uri_template = uri_template
    @params = params
  end

  def result
    http.request(
      method,
      uri.path.to_s,
      params: params.except(*uri.variables)
    )
  end

  private

  attr_reader :connection, :method, :uri_template, :params

  def http
    @http ||= Drowsy::Http.new(connection)
  end

  def uri
    @uri ||= Drowsy::Uri.new(uri_template, params)
  end
end
