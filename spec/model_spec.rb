require 'drowsy/fixtures'

RSpec.describe Drowsy::Model do
  describe '#initialize' do
    it 'accepts a hash' do
      u = User.new(name: 'sam')
      expect(u.name).to eq 'sam'
      expect(u.attributes).to include(:name)
    end

    it 'ignores unknown attributes' do
      u = User.new(definitely_not_an_attribute: 'sam')
      expect(u.attributes).not_to include(:definitely_not_an_attribute)
    end
  end

  describe '#persisted?' do
    it 'returns true if the primary key is set' do
      u = User.new(id: nil)
      expect(u.persisted?).to eq false
    end

    it 'returns false if the primary key is not set' do
      u = User.new(id: 1)
      expect(u.persisted?).to eq true
    end
  end

  describe '#attributes' do
    it 'returns a hash of all attributes' do
      u = User.new(id: 1, name: 'sam')
      expect(u.attributes).to match(id: 1, name: 'sam')
    end
  end

  describe '#assign_attributes' do
    it 'accepts a hash' do
      u = User.new
      u.assign_attributes(name: 'sam')
      expect(u.name).to eq('sam')
    end

    it 'ignores unknown attributes' do
      u = User.new
      u.assign_attributes(name: 'sam', definitely_not_an_attribute: 'bar')
      expect(u.attributes).to match(id: nil, name: 'sam')
    end
  end

  describe '#id/id=' do
    it 'manages the underlying primary key attribute'
  end

  describe '#save' do
  end

  describe '#save!' do
  end

  describe '#update' do
  end

  describe '#update!' do
  end

  describe '#destroy' do
  end

  describe '.attributes(names)' do
  end

  describe '.primary_key/primary_key=' do
  end

  describe '.known_attributes' do
  end

  describe '.all' do
  end

  describe '.where(conditions)' do
  end

  describe '.find(id)' do
  end

  describe '.create(attributes)' do
  end
end
