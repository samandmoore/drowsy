require 'drowsy/relation'

module Drowsy::Scoping
  extend ActiveSupport::Concern

  class_methods do
    delegate :find, :where, :create, to: :all

    def all
      Drowsy::Relation.new(self)
    end
  end
end
