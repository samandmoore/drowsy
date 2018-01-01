require 'sleepy/associations/base'

class Sleepy::Associations::HasOne < Sleepy::Associations::Base
  def attach
    self.tap do |association|
      name = association.name
      ivar = "@#{name}".freeze

      parent_klass.class_eval do
        define_method name do
          instance_variable_get(ivar)
        end

        define_method "#{name}=".freeze do |value|
          converted_value = association.convert(value)
          converted_value.assign_attributes(association.inverse_of_attr_name => self)

          instance_variable_set(ivar, converted_value)
        end

        define_method "build_#{name}" do |attributes = {}|
          send("#{name}=", attributes)
        end
      end
    end
  end
end
