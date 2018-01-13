require 'drowsy/http_operation'

class Drowsy::SaveOperation
  def initialize(model, http_method_override: nil)
    @model = model
    @http_method_override = http_method_override
  end

  def perform
    result = perform_http_request
    model.assign_raw_attributes(result.data)
    true
  rescue Drowsy::ResourceInvalid => e
    add_errors_to_model(e.errors) if e.errors
    false
  end

  private

  attr_reader :model

  def perform_http_request
    Drowsy::HttpOperation.new(
      model.class.connection,
      http_method,
      model.class.uri,
      model.attributes
    ).perform
  end

  def http_method
    @http_method_override || default_http_method
  end

  def default_http_method
    model.persisted? ? :put : :post
  end

  def add_errors_to_model(errors_hash)
    errors_hash.each do |attr, attr_errors|
      attr_errors.each do |error|
        model.errors.add(attr, error.delete(:message), error)
      end
    end
  end
end