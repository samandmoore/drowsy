require 'sleepy/associations/base'

class Sleepy::Associations::HasMany < Sleepy::Associations::Base
  def attach
    name = self.name
    target_klass_name = self.target_klass_name

    parent_klass.class_eval do
      define_method name do
        ivar = "@#{name}".freeze
        instance_variable_get(ivar)
      end

      define_method "#{name}=".freeze do |values|
        raise Sleepy::Error, 'value must be an Array' unless values.is_a?(Array)

        target_klass = target_klass_name.constantize
        inverse_of_attr_name = self.class.model_name.element.to_sym

        converted_values = values.map do |v|
          Functions.convert(v, target_klass).tap do |r|
            r.assign_attributes(inverse_of_attr_name => self)
          end
        end

        instance_variable_set("@#{name}".freeze, converted_values)
      end
    end
  end
end
