require 'drowsy/relation'

module Drowsy::Scoping
  extend ActiveSupport::Concern

  included do
    class_attribute :scopes
    self.scopes = {}
  end

  class_methods do
    delegate(
      :find, :find_by, :find_by!,
      :where,
      :build,
      :create, :create!,
      to: :all
    )

    def scope(name, &block)
      # use reassignment to ensure that child classes don't add to parent
      self.scopes = self.scopes.merge(name => block)
      define_singleton_method name, block
    end

    def has_scope?(name)
      scopes.key? name.to_sym
    end

    def scope_for(name)
      scopes[name.to_sym]
    end

    def all
      Drowsy::Relation.new(self)
    end
  end
end
