require 'drowsy/associations/base'

class Drowsy::Associations::BelongsTo < Drowsy::Associations::Base
  def attach
    self.tap do |association|
      name = association.name
      ivar = "@#{association.name}".freeze

      parent_klass.class_eval do
        attributes("#{association.name}_id".to_sym)

        define_method name do
          instance_variable_get(ivar)
        end

        define_method "raw_#{name}=".freeze do |raw_value|
          send("#{name}=", association.convert(raw_value))
        end

        define_method "#{name}=".freeze do |model|
          instance_variable_set(ivar, model)
          send("#{name}_id=", model.id)
        end

        define_method "#{name}_id=".freeze do |value|
          if send(name)&.id != value
            instance_variable_set(ivar, association.target_klass.new(id: value))
          end
          super(value)
        end

        define_method "build_#{name}" do |attributes = {}|
          send("#{name}=", target_klass.new(attributes))
        end
      end
    end
  end
end
