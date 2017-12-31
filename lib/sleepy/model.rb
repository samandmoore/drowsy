require 'sleepy/scoping'
require 'sleepy/persistence'
require 'active_model'

class Sleepy::Model
  include ActiveModel::Model
  include Sleepy::Scoping

  class_attribute :connection, instance_accessor: false
  class_attribute :uri, instance_accessor: false

  class_attribute :known_attributes, instance_accessor: false
  self.known_attributes = []

  def self.inherited(child_class)
    # children should inherit attributes but not add them to parent
    child_class.known_attributes = self.known_attributes.dup
  end

  def self.attributes(*names)
    unless instance_variable_defined?(:@attributes_module)
      @attributes_module = Module.new
      include @attributes_module
    end
    @attributes_module.module_eval do
      names.each do |n|
        define_method n do
          instance_variable_get "@#{n}".freeze
        end
        define_method "#{n}=" do |val|
          instance_variable_set "@#{n}".freeze, val
        end
      end
    end
    self.known_attributes.concat names
  end

  class_attribute :_primary_key, instance_accessor: false
  def self.primary_key=(value)
    self._primary_key = value
    attributes(_primary_key)
  end
  self.primary_key = :id

  def persisted?
    send(self.class._primary_key).present?
  end

  def attributes
    self.class.known_attributes.each_with_object({}) do |k, m|
      m[k] = send(k)
    end
  end

  def save
    save!
  rescue Sleepy::ModelInvalid
    false
  end

  def save!
    unless valid? && Sleepy::Persistence.new(self).save
      raise Sleepy::ModelInvalid, self
    end
    true
  end

  def update(attributes)
    update!(attributes)
  rescue Sleepy::ModelInvalid
    false
  end

  def update!(attributes)
    assign_attributes attributes
    save!
  end

  def destroy; end
end
