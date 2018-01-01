require 'sleepy/associations/base'

class Sleepy::Associations::HasOne < Sleepy::Associations::Base
  def attach
    name = self.name
    target_klass_name = self.target_klass_name

    parent_klass.class_eval do
      define_method name do
        instance_variable_get("@#{name}".freeze)
      end

      define_method "#{name}=".freeze do |value|
        target_klass = target_klass_name.constantize
        inverse_of_attr_name = self.class.model_name.element.to_sym

        converted_value = Functions.convert(value, target_klass)
        converted_value.assign_attributes(inverse_of_attr_name => self)

        instance_variable_set("@#{name}".freeze, converted_value)
      end
    end
  end
end
