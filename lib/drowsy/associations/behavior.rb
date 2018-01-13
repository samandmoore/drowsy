require 'drowsy/associations/has_many'
require 'drowsy/associations/has_one'
require 'drowsy/associations/belongs_to'

module Drowsy::Associations::Behavior
  extend ActiveSupport::Concern

  included do
    class_attribute :associations, instance_accessor: false
  end

  class_methods do
    def has_many(name, options = {})
      apply_association(Drowsy::Associations::HasMany, name, options)
    end

    def belongs_to(name, options = {})
      apply_association(Drowsy::Associations::BelongsTo, name, options)
    end

    def has_one(name, options = {})
      apply_association(Drowsy::Associations::HasOne, name, options)
    end

    def apply_association(association_klass, name, options)
      association_klass.new(self, name, options).tap do |association|
        self.associations = (self.associations || {}).merge(name => association)
        association.attach
      end
    end

    def association_names
      associations.keys
    end

    def association_raw_names
      associations.keys.map { |n| :"raw_#{n}" }
    end
  end

  def associations
    self.class.association_names.each_with_object({}) do |k, m|
      m[k] = send(k)
    end
  end
end
