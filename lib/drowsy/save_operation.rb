require 'drowsy/model_helper'
require 'drowsy/http_request'

class Drowsy::SaveOperation
  def initialize(
      model,
      http_method_override: nil,
      uri_template_override: nil,
      additional_params: {}
    )
    @model = model
    @http_method_override = http_method_override
    @uri_template_override = uri_template_override
    @additional_params = additional_params
  end

  def perform
    result = perform_http_request
    Drowsy::ModelHelper.assign_raw_attributes(model, result.data)
    true
  rescue Drowsy::ResourceInvalid => e
    add_errors_to_model(e.errors) if e.errors
    false
  end

  private

  attr_reader :model

  def add_errors_to_model(errors_hash)
    errors_hash.each do |attr, attr_errors|
      attr_errors.each do |error|
        model.errors.add(attr, error.delete(:message), error)
      end
    end
  end

  def perform_http_request
    Drowsy::HttpRequest.new(
      model.class.connection,
      http_method,
      uri_template,
      params
    ).result
  end

  def http_method
    @http_method_override || default_http_method
  end

  def default_http_method
    model.persisted? ? :put : :post
  end

  def uri_template
    @uri_template_override || default_uri_template
  end

  def default_uri_template
    model.class.uri
  end

  def params
    model.attributes.merge(@additional_params)
  end
end
