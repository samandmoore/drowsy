require 'sleepy/associations/has_many'
require 'sleepy/associations/has_one'
require 'sleepy/associations/belongs_to'

module Sleepy::Associations::Behavior
  extend ActiveSupport::Concern

  included do
    class_attribute :associations
    self.associations = {}
  end

  class_methods do
    def has_many(name, options = {})
      Sleepy::Associations::HasMany.new(self, name, options).tap do |assoc|
        associations[name] = assoc
        assoc.attach
      end
    end

    def belongs_to(name, options = {})
      Sleepy::Associations::BelongsTo.new(self, name, options).tap do |assoc|
        associations[name] = assoc
        assoc.attach
      end
    end

    def has_one(name, options = {})
      Sleepy::Associations::HasOne.new(self, name, options).tap do |assoc|
        associations[name] = assoc
        assoc.attach
      end
    end

    def association_names
      associations.keys
    end
  end
end
