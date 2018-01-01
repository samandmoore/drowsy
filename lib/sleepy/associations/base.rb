class Sleepy::Associations::Base
  attr_reader :parent_klass, :name, :options

  def initialize(parent_klass, name, options)
    @parent_klass = parent_klass
    @name = name
    @options = options
  end

  def convert(value)
    case value
    when Hash
      target_klass.new(value)
    when target_klass
      value
    else
      raise Sleepy::Error, "invalid value (#{value.inspect}) assigned to association: #{parent_klass.name}##{name}"
    end
  end

  def target_klass
    target_klass_name.constantize
  end

  def inverse_of_attr_name
    options.fetch(:inverse_of) { parent_klass.model_name.element.to_sym }.to_sym
  end

  def target_klass_name
    options.fetch(:class_name) { name.to_s.singularize.classify }.to_s
  end
end
