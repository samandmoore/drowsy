require 'drowsy/relation'
require 'drowsy/http'

module Drowsy::Scoping
  extend ActiveSupport::Concern

  class_methods do
    delegate(
      :find, :find_by, :find_by!,
      :where,
      :build,
      :create, :create!,
      *Drowsy::Http::METHODS,
      to: :all
    )

    def all
      Drowsy::Relation.new(self)
    end
  end
end
