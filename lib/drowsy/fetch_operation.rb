class Drowsy::FetchOperation
  def initialize(relation)
    @relation = relation
  end

  def perform
    new_collection_from_result(perform_http_request)
  end

  private

  attr_reader :relation

  def new_collection_from_result(result)
    case result.data
    when Array
      result.data.map { |d| new_instance(d) }
    when Hash
      [new_instance(result.data)]
    else
      raise Drowsy::ResponseError.new(result.response), 'Invalid response format'
    end
  end

  def new_instance(attributes)
    relation.klass.load(attributes)
  end

  def perform_http_request
    Drowsy::HttpOperation.new(
      relation.connection,
      :get,
      relation.uri_template,
      relation.params
    ).perform
  end
end
