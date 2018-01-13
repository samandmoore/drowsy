require 'drowsy/uri'
require 'drowsy/http'

class Drowsy::HttpOperation
  def initialize(connection, method, uri_template, params)
    @connection = connection
    @method = method
    @uri_template = uri_template
    @params = params
  end

  def perform
    http_connection.request(
      method,
      uri.path.to_s,
      params: params.except(*uri.variables)
    )
  end

  private

  attr_reader :connection, :method, :uri_template, :params

  def http_connection
    @http_connection ||= Drowsy::Http.new(connection)
  end

  def uri
    @uri ||= Drowsy::Uri.new(uri_template, params)
  end
end
