require 'sleepy/scoping'
require 'active_model'

class Sleepy::Model
  include ActiveModel::Model
  include Sleepy::Scoping

  class_attribute :connection
  class_attribute :uri

  def self.inherited(child_class)
    # children should inherit attributes but not add them to parent
    child_class.known_attributes = self.known_attributes.dup
  end

  class_attribute :known_attributes
  self.known_attributes = []

  def self.attributes(*names)
    mod = Module.new
    mod.module_eval do
      names.each do |n|
        define_method n do
          instance_variable_get "@#{n}".freeze
        end
        define_method "#{n}=" do |val|
          instance_variable_set "@#{n}".freeze, val
        end
      end
    end
    include mod
    self.known_attributes.concat names
  end

  def save; end
  def update(attributes); end
  def destroy; end
end
