require 'active_model'
require 'drowsy/attributes'
require 'drowsy/scoping'
require 'drowsy/associations'
require 'drowsy/persistence'
require 'drowsy/model_inspector'

class Drowsy::Model
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include Drowsy::Attributes
  include Drowsy::Scoping
  include Drowsy::Associations::Behavior

  define_model_callbacks :create, :update, :save, :destroy

  class_attribute :connection, instance_accessor: false
  class_attribute :uri, instance_accessor: false

  # special because it includes .association_names
  # to support embedded associations in API responsees
  def self.assignable_attributes
    (
      [primary_key] + known_attributes + association_names
    ).uniq
  end

  def assign_attributes(new_attributes)
    # ignore unknown attributes
    super(new_attributes.extract!(*self.class.assignable_attributes))
  end

  def persisted?
    id.present?
  end

  def save
    if valid?
      callback = persisted? ? :update : :create
      run_callbacks callback do
        run_callbacks :save do
          Drowsy::Persistence.new(self).save
        end
      end
    end
  end

  def save!
    save || raise(Drowsy::ModelInvalid, self)
  end

  def update(attributes)
    assign_attributes attributes
    save
  end

  def update!(attributes)
    update(attributes) || raise(Drowsy::ModelInvalid, self)
  end

  def destroy
    run_callbacks :destroy do
      Drowsy::Persistence.new(self).destroy
    end
  end

  def inspect
    ModelInspector.inspect(self)
  end
end
