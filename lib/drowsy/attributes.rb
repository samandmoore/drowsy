module Drowsy::Attributes
  extend ActiveSupport::Concern

  included do
    class_attribute :primary_key, instance_accessor: false
    class_attribute :known_attributes, instance_accessor: false
    self.known_attributes = []
    self.primary_key = :id
  end

  class_methods do
    def attributes(*names)
      unless instance_variable_defined?("@attributes_module".freeze)
        @attributes_module = Module.new
        include @attributes_module
      end
      @attributes_module.module_eval do
        names.each do |n|
          define_method n do
            read_attribute(n)
          end
          define_method "#{n}=".freeze do |val|
            write_attribute(n, val)
          end
        end
      end
      # += here makes sure that if we call .attributes
      # in a child of a Drowsy::Model, we won't define
      # methods on the parent class
      self.known_attributes += names
    end

    def serializable_attributes
      ([primary_key] + known_attributes).uniq
    end
  end

  def id
    read_attribute(self.class.primary_key)
  end

  def id=(value)
    write_attribute(self.class.primary_key, value)
  end

  def attributes
    self.class.serializable_attributes.each_with_object({}) do |k, m|
      m[k] = send(k) # use #send to invoke full getter
    end
  end

  def read_attribute(name)
    instance_variable_get("@#{name}".freeze)
  end

  def write_attribute(name, value)
    instance_variable_set("@#{name}".freeze, value)
  end
end
