require 'sleepy/relation'

module Sleepy::Scoping
  extend ActiveSupport::Concern

  class_methods do
    def all
      Sleepy::Relation.new(self)
    end
  end
end
