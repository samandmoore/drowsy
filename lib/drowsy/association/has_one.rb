require 'drowsy/association/base'

class Drowsy::Association::HasOne < Drowsy::Association::Base
  def attach
    self.tap do |association|
      name = association.name
      ivar = "@#{name}".freeze

      parent_klass.class_eval do
        define_method name do
          instance_variable_get(ivar)
        end

        define_method "raw_#{name}=".freeze do |raw_value|
          send("#{name}=", association.convert(raw_value))
        end

        define_method "#{name}=".freeze do |model|
          raise Drowsy::Error, "model must be a #{association.target_klass}" unless model.is_a?(association.target_klass)
          model.assign_attributes(association.inverse_of_attr_name => self)
          instance_variable_set(ivar, model)
        end

        define_method "build_#{name}" do |attributes = {}|
          send("#{name}=", target_klass.new(attributes))
        end
      end
    end
  end
end
