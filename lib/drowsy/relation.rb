class Drowsy::Relation
  include Enumerable

  delegate :to_ary, :[], :any?, :empty?, :last, :size, :each, to: :fetch

  attr_accessor :params

  def initialize(klass)
    @klass = klass
    @connection = klass.connection
    @uri_template = klass.uri
    @params = {}
  end

  def build(attributes = {})
    klass.new(params.merge(attributes))
  end

  def create(attributes = {})
    build(attributes).tap(&:save)
  end

  def create!(attributes = {})
    build(attributes).tap(&:save!)
  end

  def destroy_existing(id); raise NotImplementedError; end
  def save_existing(id, attributes); raise NotImplementedError; end
  def update_existing(id, attributes); raise NotImplementedError; end

  def find(id)
    where(klass.primary_key => id).fetch.first
  end

  def where(conditions)
    clone.tap do |r|
      r.params = params.merge(conditions)
    end
  end

  protected

  def fetch
    @fetch ||= new_collection_from_result(perform_http_request(:get))
  end

  private

  attr_reader :klass, :connection, :uri_template

  def uri
    @uri ||= Drowsy::Uri.new(uri_template, params)
  end

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
    klass.new(attributes)
  end

  def perform_http_request(method)
    Drowsy::Http.new(connection).request(method, uri.path.to_s, params: params.except(*uri.variables))
  end
end
