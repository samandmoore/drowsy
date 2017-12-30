class Sleepy::Relation
  include Enumerable

  delegate :to_ary, :[], :any?, :empty?, :last, :size, to: :fetch_some

  def initialize(klass)
    @klass = klass
    @connection = klass.connection
    @uri = klass.uri
  end

  def self.find(id); end
  def self.all; end
  def self.where(conditions); end
  def self.create(attributes); end
  def self.destroy_existing(id); end
  def self.save_existing(id, attributes); end
  def self.update_existing(id, attributes); end

  def each(&block)
    fetch_some.each(&block)
  end

  def fetch_some
    @fetch_some ||= new_collection(Sleepy::Http.new(connection).get(uri).data)
  end

  private

  def new_collection(items)
    items.map { |d| new_instance(d) }
  end

  def new_instance(item)
    klass.new(item)
  end

  private

  attr_reader :klass, :connection, :uri
end
