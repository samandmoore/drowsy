require 'sleepy/fakes'

RSpec.describe Sleepy::Model do
  describe '#initialize' do
    it 'accepts a hash'
    it 'ignores unknown attributes'
  end

  describe '#persisted?' do
    it 'returns true if the primary key is set'
    it 'returns false if the primary key is not set'
  end

  describe '#attributes' do
    it 'returns a hash of all attributes'
  end

  describe '#assign_attributes' do
    it 'accepts a hash'
    it 'ignores unknown attributes'
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
