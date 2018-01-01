require 'addressable/template'

class Drowsy::Uri
  def initialize(raw_template, attributes = {})
    @raw_template = raw_template
    @attributes = attributes
  end

  def path
    template.expand(attributes)
  end

  def variables
    template.variables.map(&:to_sym)
  end

  private

  def template
    @template ||= Addressable::Template.new(raw_template)
  end

  attr_reader :raw_template, :attributes
end
