class Sleepy::Persistence
  def initialize(model)
    @model = model
    @connection = model.class.connection
    @uri_template = model.class.uri
    @params = model.attributes
  end

  def save
    result = if model.persisted?
               perform_http_request(:put)
             else
               perform_http_request(:post)
             end
    model.assign_attributes(result.data)
    true
  rescue Sleepy::ResourceInvalid => e
    if e.errors
      add_errors_to_model(e.errors)
      false
    end
  end

  private

  attr_reader :model, :connection, :uri_template, :params

  def uri
    @uri ||= Sleepy::Uri.new(uri_template, params)
  end

  def perform_http_request(method)
    Sleepy::Http.new(connection).request(method, uri.path.to_s, params: params.except(*uri.variables))
  end

  def add_errors_to_model(errors_hash)
    errors_hash.each do |attr, attr_errors|
      attr_errors.each do |error|
        model.errors.add(attr, error.delete(:message), error)
      end
    end
  end
end
