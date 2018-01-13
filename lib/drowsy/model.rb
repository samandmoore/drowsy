require 'active_model'
require 'drowsy/attributes'
require 'drowsy/scoping'
require 'drowsy/associations'
require 'drowsy/persistence'
require 'drowsy/model_inspector'

class Drowsy::Model
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include Drowsy::Attributes
  include Drowsy::Scoping
  include Drowsy::Associations::Behavior

  define_model_callbacks :create, :update, :save, :destroy

  class_attribute :connection, instance_accessor: false
  class_attribute :uri, instance_accessor: false

  # support embedded associations in API responsees
  # by including additional special attribute types
  # * primary_key
  # * .association_names
  # * .association_raw_names
  def self.assignable_attributes
    (
      [primary_key] + known_attributes + association_names + association_raw_names
    ).uniq
  end

  def assign_attributes(new_attributes)
    # ignore unknown attributes
    super(new_attributes.extract!(*self.class.assignable_attributes))
  end

  def initialize(_persisted: false, **args)
    @persisted = _persisted
    super(**args)
  end

  # used to load an instance from raw attributes
  # this method will mark all models as persisted when
  # building the object graph for the raw attributes
  def self.load(attributes)
    result = attributes.each_with_object({}) do |(key, value), memo|
      if association_names.include?(key)
        memo[:"raw_#{key}"] = value
      else
        memo[key] = value
      end
    end
    new(_persisted: true, **result)
  end

  def persisted?
    @persisted.present?
  end

  def save
    if valid?
      callback = persisted? ? :update : :create
      run_callbacks callback do
        run_callbacks :save do
          Drowsy::Persistence.new(self).save.tap do |result|
            @persisted = persisted? | result
          end
        end
      end
    end
  end

  def save!
    save || raise(Drowsy::ModelInvalid, self)
  end

  def update(attributes)
    assign_attributes attributes
    save
  end

  def update!(attributes)
    update(attributes) || raise(Drowsy::ModelInvalid, self)
  end

  def destroy
    run_callbacks :destroy do
      Drowsy::Persistence.new(self).destroy.tap do |result|
        @destroyed = destroyed? | result
      end
    end
  end

  def destroyed?
    @destroyed.present?
  end

  def hash
    id.hash
  end

  def ==(other)
    other.instance_of?(self.class) && id.present? && id == other.id
  end
  alias :eql? :==

  def inspect
    Drowsy::ModelInspector.inspect(self)
  end
end
