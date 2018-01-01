require 'sleepy/associations/base'

class Sleepy::Associations::BelongsTo < Sleepy::Associations::Base
  def attach
    name = self.name
    target_klass_name = self.target_klass_name

    parent_klass.class_eval do
      attributes("#{name}_id".to_sym)

      define_method name do
        instance_variable_get("@#{name}".freeze)
      end

      define_method "#{name}=".freeze do |value|
        target_klass = target_klass_name.constantize
        converted_value = Functions.convert(value, target_klass)
        instance_variable_set("@#{name}".freeze, converted_value)
        send("#{name}_id=", converted_value.id)
      end

      define_method "#{name}_id=".freeze do |value|
        if send(name)&.id != value
          target_klass = target_klass_name.constantize
          instance_variable_set("@#{name}".freeze, target_klass.new(id: value))
        end
        super(value)
      end

      define_method "build_#{name}" do |attributes = {}|
        send("#{name}=", m)
      end
    end
  end
end
