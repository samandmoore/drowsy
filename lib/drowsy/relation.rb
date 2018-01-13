class Drowsy::Relation
  include Enumerable

  delegate :to_ary, :[], :any?, :empty?, :last, :size, :each, to: :fetch

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

  # given an identifer
  # send a DELETE request to the resource
  # with the given id.
  # @return true/false
  def destroy_existing(id);
    klass.load(id: id).destroy
  end

  # given an identifer and attributes
  # send a PUT request with the attributes for
  # the resource with the given id.
  # @return true/false
  def update_existing(id, attributes)
    klass.load(attributes.merge(id: id)).save
  end

  def find(id)
    find_by!(klass.primary_key => id)
  end

  def find_by(attributes)
    find_by!(attributes)
  rescue Drowsy::ResourceNotFound
    nil
  end

  def find_by!(attributes)
    where(attributes).fetch.first
  end

  def where(conditions)
    clone.tap do |r|
      r.params = params.merge(conditions)
    end
  end

  protected

  attr_accessor :params

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
    klass.load(attributes)
  end

  def perform_http_request(method)
    Drowsy::Http.new(connection).request(method, uri.path.to_s, params: params.except(*uri.variables))
  end
end
