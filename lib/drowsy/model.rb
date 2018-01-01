require 'drowsy/scoping'
require 'drowsy/persistence'
require 'drowsy/associations'
require 'active_model'

class Drowsy::Model
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include Drowsy::Scoping
  include Drowsy::Associations::Behavior

  define_model_callbacks :create, :update, :save, :destroy

  class_attribute :connection, instance_accessor: false
  class_attribute :uri, instance_accessor: false

  class_attribute :known_attributes, instance_accessor: false
  self.known_attributes = []

  def self.inherited(child_class)
    # children should inherit attributes but not add them to parent
    child_class.known_attributes = self.known_attributes.dup
  end

  def self.attributes(*names)
    unless instance_variable_defined?("@attributes_module".freeze)
      @attributes_module = Module.new
      include @attributes_module
    end
    @attributes_module.module_eval do
      names.each do |n|
        define_method n do
          instance_variable_get "@#{n}".freeze
        end
        define_method "#{n}=".freeze do |val|
          instance_variable_set "@#{n}".freeze, val
        end
      end
    end
    self.known_attributes.concat names
  end

  class_attribute :_primary_key, instance_accessor: false
  def self.primary_key=(name)
    if self._primary_key && self._primary_key != :id
      undef_method(self._primary_key)
      undef_method("#{self._primary_key}=".freeze)
    end
    self._primary_key = name
    attributes(name)
  end
  def self.primary_key
    self._primary_key
  end
  self.primary_key = :id

  def assign_attributes(new_attributes)
    # ignore unknown attributes
    super(new_attributes.extract!(*(self.class.known_attributes + self.class.association_names)))
  end

  def id
    instance_variable_get("@#{self.class.primary_key}".freeze)
  end

  def id=(value)
    instance_variable_set("@#{self.class.primary_key}".freeze, value)
  end

  def persisted?
    id.present?
  end

  def attributes
    self.class.known_attributes.each_with_object(
      { self.class.primary_key => id }
    ) do |k, m|
      m[k] = send(k)
    end
  end

  def save
    if valid?
      callback = persisted? ? :update : :create
      run_callbacks callback do
        run_callbacks :save do
          Drowsy::Persistence.new(self).save
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
      Drowsy::Persistence.new(self).destroy
    end
  end
end
