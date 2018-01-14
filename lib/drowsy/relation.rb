require 'drowsy/fetch_operation'

class Drowsy::Relation
  include Enumerable

  attr_reader :klass

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

  def to_http_request
    Drowsy::HttpRequest.new(connection, :get, uri_template, params)
  end

  def inspect
    "#<Drowsy::Relation[#{klass}](#{uri_template})#{params.map { |k, v| " #{k}: #{v.inspect}" }.join('')}>"
  end

  protected

  attr_writer :params

  def fetch
    @fetch ||= Drowsy::FetchOperation.new(self).perform
  end

  private

  attr_reader :connection, :uri_template, :params
end
