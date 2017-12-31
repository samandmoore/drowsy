require 'sleepy/relation'

module Sleepy::Scoping
  extend ActiveSupport::Concern

  class_methods do
    delegate :find, :where, to: :all

    def all
      Sleepy::Relation.new(self)
    end
  end
end
