class Sleepy::Relation
  include Enumerable

  delegate :to_ary, :[], :any?, :empty?, :last, :size, to: :fetch_some

  attr_accessor :params

  def initialize(klass)
    @klass = klass
    @connection = klass.connection
    @uri_template = klass.uri
    @params = {}
  end

  def self.create(attributes); end
  def self.destroy_existing(id); end
  def self.save_existing(id, attributes); end
  def self.update_existing(id, attributes); end

  def each(&block)
    fetch_some.each(&block)
  end

  def find(id)
    where(klass.primary_key => id).fetch_one
  end

  def where(conditions)
    clone.tap do |r|
      r.params = params.merge(conditions)
    end
  end

  protected

  def fetch_one
    @fetch_one ||= new_instance(http.get(path, params: params.except(uri.variables)).data)
  end

  def fetch_some
    @fetch_some ||= new_collection(http.get(path, params: params.except(uri.variables)).data)
  end

  private

  attr_reader :klass, :connection, :uri_template

  def new_collection(items)
    items.map { |d| new_instance(d) }
  end

  def new_instance(item)
    klass.new(item)
  end

  def http
    Sleepy::Http.new(connection)
  end

  def path
    uri.path.to_s
  end

  def uri
    @uri ||= Sleepy::Uri.new(uri_template, params)
  end
end
