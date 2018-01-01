require 'sleepy/associations/base'

class Sleepy::Associations::BelongsTo < Sleepy::Associations::Base
  def attach
    self.tap do |association|
      name = association.name
      ivar = "@#{association.name}".freeze

      parent_klass.class_eval do
        attributes("#{association.name}_id".to_sym)

        define_method name do
          instance_variable_get(ivar)
        end

        define_method "#{name}=".freeze do |value|
          converted_value = association.convert(value)
          instance_variable_set(ivar, converted_value)
          send("#{name}_id=", converted_value.id)
        end

        define_method "#{name}_id=".freeze do |value|
          if send(name)&.id != value
            instance_variable_set(ivar, association.target_klass.new(id: value))
          end
          super(value)
        end

        define_method "build_#{name}" do |attributes = {}|
          send("#{name}=", m)
        end
      end
    end
  end
end
