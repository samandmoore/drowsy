require 'drowsy/model_helper'

class Drowsy::Associations::Base
  attr_reader :parent_klass, :name, :options

  def initialize(parent_klass, name, options)
    @parent_klass = parent_klass
    @name = name
    @options = options
  end

  def convert(raw_value)
    case raw_value
    when Hash
      Drowsy::ModelHelper.construct(target_klass, raw_value)
    when target_klass
      raw_value
    else
      raise Drowsy::Error, "invalid value (#{raw_value.inspect}) assigned to association: #{parent_klass.name}##{name}"
    end
  end

  def target_klass
    target_klass_name.constantize
  end

  def inverse_of_attr_name
    # FIXME: the defaulting currently only works for one-to-one inverses
    options.fetch(:inverse_of) { parent_klass.model_name.element.to_sym }.to_sym
  end

  def target_klass_name
    options.fetch(:class_name) { name.to_s.singularize.classify }.to_s
  end
end
