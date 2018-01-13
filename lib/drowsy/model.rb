require 'active_model'
require 'drowsy/attributes'
require 'drowsy/scoping'
require 'drowsy/associations'
require 'drowsy/model_inspector'
require 'drowsy/save_operation'
require 'drowsy/destroy_operation'

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
      [:id, primary_key] + known_attributes + association_names + association_raw_names
    ).uniq
  end

  def assign_attributes(new_attributes)
    # ignore unknown attributes
    super(new_attributes.extract!(*self.class.assignable_attributes))
  end

  def assign_raw_attributes(raw_attributes)
    assign_attributes(self.class.translate_raw_attributes(raw_attributes))
  end

  # load an instance from raw attributes
  def self.load(raw_attributes)
    new(**translate_raw_attributes(raw_attributes))
  end

  def self.translate_raw_attributes(raw_attributes)
    raw_attributes.each_with_object({}) do |(key, value), memo|
      if association_names.include?(key)
        memo[:"raw_#{key}"] = value
      else
        memo[key] = value
      end
    end
  end

  def persisted?
    id.present?
  end

  def save
    return false unless valid?

    callback = persisted? ? :update : :create
    run_callbacks callback do
      run_callbacks :save do
        Drowsy::SaveOperation.new(self).perform
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
      Drowsy::DestroyOperation.new(self).perform.tap do |result|
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
