require 'drowsy/associations/base'

class Drowsy::Associations::HasMany < Drowsy::Associations::Base
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

        define_method "raw_#{name}=".freeze do |raw_values|
          raise Drowsy::Error, 'value must be an Array' unless raw_values.is_a?(Array)

          send("#{name}=".freeze, association.convert_many(raw_values))
        end

        define_method "#{name}=".freeze do |models|
          raise Drowsy::Error, 'models must be an Array' unless models.is_a?(Array)

          models.each do |model|
            raise Drowsy::Error, "model must be a #{association.target_klass}" unless model.is_a?(association.target_klass)
            model.assign_attributes(association.inverse_of_attr_name => self)
          end

          instance_variable_set(ivar, association.build_proxy(self, models))
        end
      end
    end
  end

  def build_proxy(parent, models = Array.new)
    AssociationProxy.new(parent, self, models)
  end

  def convert_many(raw_values)
    raw_values.map do |raw_value|
      convert(raw_value)
    end
  end

  class AssociationProxy < SimpleDelegator
    def initialize(parent, association, models)
      super(models)
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
