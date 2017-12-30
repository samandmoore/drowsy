class Sleepy::Model
  class_attribute :connection
  class_attribute :uri

  def save; end
  def update(attributes); end
  def destroy; end
  def self.find(id); end
  def self.all; end
  def self.where(conditions); end
  def self.create(attributes); end
  def self.destroy_existing(id); end
  def self.save_existing(id, attributes); end
  def self.update_existing(id, attributes); end
end
