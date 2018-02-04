require 'drowsy/relation'
require 'drowsy/http'

module Drowsy::Scoping
  extend ActiveSupport::Concern

  class_methods do
    delegate(
      :find, :find_by, :find_by!,
      :all,
      :where,
      :build,
      :create, :create!,
      *Drowsy::Http::METHODS,
      to: :blank_relation
    )

    def scope(name, behavior)
      define_singleton_method name, behavior
      blank_relation.define_singleton_method(name, behavior)
    end

    def blank_relation
      @blank_relation ||= Drowsy::Relation.new(self)
    end
  end
end
