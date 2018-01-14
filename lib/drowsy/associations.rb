module Drowsy::Association
end

require 'drowsy/association/has_many'
require 'drowsy/association/has_one'
require 'drowsy/association/belongs_to'

module Drowsy::Associations
  extend ActiveSupport::Concern

  included do
    class_attribute :associations, instance_accessor: false
    self.associations = {}.freeze
  end

  class_methods do
    def has_many(name, options = {})
      apply_association(Drowsy::Association::HasMany, name, options)
    end

    def belongs_to(name, options = {})
      apply_association(Drowsy::Association::BelongsTo, name, options)
    end

    def has_one(name, options = {})
      apply_association(Drowsy::Association::HasOne, name, options)
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
