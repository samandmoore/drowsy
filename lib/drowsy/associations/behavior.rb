require 'drowsy/associations/has_many'
require 'drowsy/associations/has_one'
require 'drowsy/associations/belongs_to'

module Drowsy::Associations::Behavior
  extend ActiveSupport::Concern

  included do
    class_attribute :associations
    self.associations = {}
  end

  class_methods do
    def has_many(name, options = {})
      Drowsy::Associations::HasMany.new(self, name, options).tap do |assoc|
        associations[name] = assoc
        assoc.attach
      end
    end

    def belongs_to(name, options = {})
      Drowsy::Associations::BelongsTo.new(self, name, options).tap do |assoc|
        associations[name] = assoc
        assoc.attach
      end
    end

    def has_one(name, options = {})
      Drowsy::Associations::HasOne.new(self, name, options).tap do |assoc|
        associations[name] = assoc
        assoc.attach
      end
    end

    def association_names
      associations.keys
    end
  end
end
