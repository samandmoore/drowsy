require 'spec_helper'

RSpec.describe Drowsy::Model do
  let(:connection) do
    Faraday.new(url: 'https://test.dev') do |c|
      c.request   :json
      c.use       Drowsy::JsonParser
      c.response  :logger, nil, bodies: true
      c.adapter   Faraday.default_adapter
    end
  end

  before do
    klass = Class.new(Drowsy::Model) do
      self.uri = '/users{/id}'
      self.connection = connection
    end
    stub_const('TestUser', klass)
  end

  describe '#initialize' do
    before do
      TestUser.class_eval do
        attributes :name
      end
    end

    it 'accepts a hash' do
      u = TestUser.new(name: 'sam')
      expect(u.name).to eq 'sam'
      expect(u.attributes).to include(:name)
    end

    it 'ignores unknown attributes' do
      u = TestUser.new(definitely_not_an_attribute: 'sam')
      expect(u.attributes).not_to include(:definitely_not_an_attribute)
    end
  end

  describe '#persisted?' do
    it 'returns true if the primary key is set' do
      u = TestUser.new(id: nil)
      expect(u.persisted?).to eq false
    end

    it 'returns false if the primary key is not set' do
      u = TestUser.new(id: 1)
      expect(u.persisted?).to eq true
    end
  end

  describe '#attributes' do
    before do
      TestUser.class_eval do
        attributes :name
      end
    end

    it 'returns a hash of all attributes' do
      u = TestUser.new(id: 1, name: 'sam')
      expect(u.attributes).to match(id: 1, name: 'sam')
    end
  end

  describe '#assign_attributes' do
    before do
      TestUser.class_eval do
        attributes :name
      end
    end

    it 'accepts a hash' do
      u = TestUser.new
      u.assign_attributes(name: 'sam')
      expect(u.name).to eq('sam')
    end

    it 'ignores unknown attributes' do
      u = TestUser.new
      u.assign_attributes(name: 'sam', definitely_not_an_attribute: 'bar')
      expect(u.attributes).to match(id: nil, name: 'sam')
    end
  end

  describe '#id/id=' do
    before do
      TestUser.class_eval do
        self.primary_key = :special_id
        attributes :special_id
      end
    end

    it 'manages the underlying primary key attribute' do
      u = TestUser.new(id: 1)
      expect(u.id).to eq(1)
      expect(u.special_id).to eq(1)

      u.id = 2
      expect(u.id).to eq(2)
      expect(u.special_id).to eq(2)

      expect(u.attributes).to include(special_id: 2)
    end
  end

  describe '#save' do
    context 'for unpersisted records' do
      it 'performs a POST' do

      end
    end
  end

  describe '#save!' do
  end

  describe '#update' do
  end

  describe '#update!' do
  end

  describe '#destroy' do
  end

  describe '.find(id)' do
    it 'responds to the method' do
      expect(TestUser.respond_to?(:find)).to eq(true)
    end
  end

  describe '.create(attributes)' do
    it 'responds to the method' do
      expect(TestUser.respond_to?(:create)).to eq(true)
    end
  end

  describe '.all' do
    it 'returns a Relation' do
      expect(TestUser.all).to be_a(Drowsy::Relation)
    end
  end

  describe '.where(conditions)' do
    it 'delegates to Relation' do
      expect(TestUser.where(Hash.new)).to be_a(Drowsy::Relation)
    end
  end

  describe 'class definition methods' do
    describe '.attributes(names)' do
      it 'defines getters and setters for named attributes' do
        TestUser.class_eval do
          attributes :name, :place
        end

        u = TestUser.new
        expect(u.respond_to?(:name)).to eq(true)
        expect(u.respond_to?(:name=)).to eq(true)

        expect(u.respond_to?(:place)).to eq(true)
        expect(u.respond_to?(:place=)).to eq(true)
      end

      it 'adds the attributes to .known_attributes' do
        TestUser.class_eval do
          attributes :name, :place
        end

        expect(TestUser.known_attributes).to contain_exactly(:name, :place)
      end
    end

    describe '.known_attributes' do
      before do
        TestUser.class_eval do
          attributes :name
        end

        klass = Class.new(TestUser)
        stub_const('TestAdminUser', klass)
      end

      it 'includes attributes from .attributes setup' do
        expect(TestUser.known_attributes).to contain_exactly(:name)
      end

      context 'for an inherited model' do
        it 'includes attributes from parent and child' do
          TestAdminUser.class_eval do
            attributes :special_id, :role
          end

          expect(TestAdminUser.known_attributes).to contain_exactly(:special_id, :role, :name)
        end
      end
    end

    describe '.primary_key/primary_key=' do
      it 'specifies the attribute managed by id/id=' do
        TestUser.class_eval do
          self.primary_key = :something_id
          self.attributes :something_id
        end

        u = TestUser.new
        u.id = 1
        expect(u.attributes).to match(something_id: 1)

        u = TestUser.new(something_id: 1)
        expect(u.id).to eq(1)
      end
    end
  end
end
