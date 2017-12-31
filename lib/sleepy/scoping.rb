require 'sleepy/relation'

module Sleepy::Scoping
  extend ActiveSupport::Concern

  class_methods do
    delegate :find, to: :all

    def all
      Sleepy::Relation.new(self)
    end
  end
end

require 'addressable/template'
class Sleepy::Uri
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
