require 'drowsy/associations/base'

class Drowsy::Associations::HasOne < Drowsy::Associations::Base
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
