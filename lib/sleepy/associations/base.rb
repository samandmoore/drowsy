class Sleepy::Associations::Base
  attr_reader :parent_klass, :name, :options

  def initialize(parent_klass, name, options)
    @parent_klass = parent_klass
    @name = name
    @options = options
  end

  def target_klass_name
    options.fetch(:class_name) { name.to_s.singularize.classify }.to_s
  end

  module Functions
    def self.convert(value, target_klass)
      case value
      when Hash
        target_klass.new(value)
      when target_klass
        value
      else
        raise Sleepy::Error, "invalid type in association: #{value.class}"
      end
    end
  end
end
