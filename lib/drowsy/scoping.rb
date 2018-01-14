require 'drowsy/relation'

module Drowsy::Scoping
  extend ActiveSupport::Concern

  class_methods do
    delegate(
      :find, :find_by, :find_by!,
      :where,
      :build,
      :create, :create!,
      to: :all
    )

    def all
      Drowsy::Relation.new(self)
    end
  end
end
