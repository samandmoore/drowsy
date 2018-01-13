require 'drowsy/http_operation'

class Drowsy::DestroyOperation
  def initialize(model)
    @model = model
  end

  def perform
    perform_http_request
    true
  end

  private

  attr_reader :model

  def perform_http_request
    Drowsy::HttpOperation.new(
      model.class.connection,
      :delete,
      model.class.uri,
      { model.class.primary_key => model.id }
    ).perform
  end
end
