require 'sleepy/associations/base'

class Sleepy::Associations::HasMany < Sleepy::Associations::Base
  def attach
    self.tap do |association|
      name = association.name
      ivar = "@#{association.name}".freeze

      parent_klass.class_eval do
        define_method name do
          unless instance_variable_defined?(ivar)
            instance_variable_set(ivar, association.build_proxy(self))
          end
          instance_variable_get(ivar)
        end

        define_method "#{name}=".freeze do |values|
          raise Sleepy::Error, 'value must be an Array' unless values.is_a?(Array)

          converted_values = association.convert_many(values)
          converted_values.each do |r|
            r.assign_attributes(association.inverse_of_attr_name => self)
          end

          instance_variable_set(ivar, association.build_proxy(self, converted_values))
        end
      end
    end
  end

  def build_proxy(parent, values = Array.new)
    AssociationProxy.new(parent, self, values)
  end

  def convert_many(values)
    values.map do |v|
      convert(v)
    end
  end

  class AssociationProxy < SimpleDelegator
    def initialize(parent, association, collection)
      super(collection)
      @parent = parent
      @association = association
    end

    def build(attributes = {})
      association.target_klass.new(attributes.merge(association.inverse_of_attr_name => parent)).tap do |item|
        __getobj__ << item
      end
    end

    private

    attr_reader :parent, :association
  end
end
