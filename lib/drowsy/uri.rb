require 'addressable/template'

class Drowsy::Uri
  class << self
    def join_or_replace(*parts)
      parts = parts.compact
      if parts.size == 1
        parts.first.to_s
      elsif parts.size == 2 && parts.second.is_a?(String)
        parts.second.to_s
      else
        parts.join('/').gsub(%r{//}, '/')
      end
    end
  end

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
