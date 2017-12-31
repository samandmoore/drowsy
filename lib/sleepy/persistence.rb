class Sleepy::Persistence
  def initialize(model)
    @model = model
    @connection = model.class.connection
    @uri_template = model.class.uri
    @params = model.attributes
  end

  def save
    method = model.persisted? ? :put : :post
    result = perform_http_request(method)
    model.assign_attributes(result.data)
    true
  rescue Sleepy::ResourceInvalid => e
    if e.errors
      add_errors_to_model(e.errors)
      false
    end
  end

  def destroy
    self.params = { model.class.primary_key => model.id }
    perform_http_request(:delete)
    true
  end

  private

  attr_reader :model, :connection, :uri_template
  attr_accessor :params

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
