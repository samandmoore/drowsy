require 'drowsy/fetch_operation'

class Drowsy::Relation
  include Enumerable

  attr_reader :klass, :params

  delegate :to_ary, :[], :any?, :empty?, :last, :size, :each, to: :fetch

  def initialize(klass)
    @klass = klass
    @connection = klass.connection
    @uri_template = klass.uri
    @http_method = :get
    @params = {}
  end

  # defines get, put, post, patch, delete
  Drowsy::Http::METHODS.each do |http_method|
    define_method http_method do |uri_template = nil, **params|
      where(params)
        .with_http_method(http_method)
        .with_uri(uri_template)
        .fetch
    end
  end

  def all
    self
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
    Array(where(attributes).fetch).first
  end

  def where(conditions)
    chain do |r|
      r.params = params.merge(conditions)
    end
  end

  def with_http_method(http_method)
    chain do |r|
      r.http_method = http_method
    end
  end

  def with_uri(uri)
    chain do |r|
      r.uri_template = Drowsy::Uri.join_or_replace(uri_template, uri)
    end
  end

  def to_http_request
    Drowsy::HttpRequest.new(connection, http_method, uri_template, params)
  end

  def inspect
    "#<Drowsy::Relation[#{klass}](#{uri_template})#{params.map { |k, v| " #{k}: #{v.inspect}" }.join('')}>"
  end

  protected

  attr_writer :params, :http_method, :uri_template

  def fetch
    @fetch ||= Drowsy::FetchOperation.new(self).perform
  end

  def clear_result!
    @fetch = nil
  end

  def chain
    clone.tap do |relation|
      relation.clear_result!
      yield relation
    end
  end

  private

  attr_reader :connection, :http_method, :uri_template
end
