require 'active_model'
require 'drowsy/attributes'
require 'drowsy/scoping'
require 'drowsy/associations'
require 'drowsy/model_inspector'
require 'drowsy/save_operation'

class Drowsy::Model
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include Drowsy::Attributes
  include Drowsy::Scoping
  include Drowsy::Associations

  define_model_callbacks :create, :update, :save, :destroy

  class_attribute :connection, instance_accessor: false
  class_attribute :uri, instance_accessor: false

  # given an identifer
  # send a DELETE request to the resource
  # with the given id.
  # @return true/false
  def self.destroy_existing(id)
    new(id: id).destroy
  end

  # given an identifer and attributes
  # send a PUT request with the attributes for
  # the resource with the given id.
  # @return true/false
  def self.update_existing(id, attributes)
    new(attributes.merge(id: id)).save
  end

  # support embedded associations in API responsees
  # by including additional special attribute types
  # * primary_key
  # * .association_names
  # * .association_raw_names
  def self.assignable_attributes
    (
      [:id, primary_key] + known_attributes + association_names + association_raw_names
    ).uniq
  end

  def assign_attributes(new_attributes)
    # ignore unknown attributes
    super(new_attributes.extract!(*self.class.assignable_attributes))
  end

  def persisted?
    id.present?
  end

  # defines get, put, post, patch, delete
  Drowsy::Http::METHODS.each do |http_method|
    define_method http_method do |uri_template = nil, **params|
      uri = Drowsy::Uri.join_or_replace(self.class.uri, uri_template)
      _save(
        http_method_override: http_method,
        uri_template_override: uri,
        additional_params: params
      )
    end
  end

  def save
    return false unless valid?

    callback = persisted? ? :update : :create
    run_callbacks callback do
      run_callbacks :save do
        _save
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
    return false unless valid?

    run_callbacks :destroy do
      _save(http_method_override: :delete).perform.tap do |result|
        @destroyed = destroyed? | result
      end
    end
  end

  def destroyed?
    @destroyed.present?
  end

  def hash
    id.hash
  end

  def ==(other)
    other.instance_of?(self.class) && id.present? && id == other.id
  end
  alias eql? ==

  def inspect
    Drowsy::ModelInspector.inspect(self)
  end

  private

  def _save(**args)
    Drowsy::SaveOperation.new(self, **args).perform
  end
end
