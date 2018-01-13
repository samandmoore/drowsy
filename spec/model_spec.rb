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
    it 'manages the underlying primary key attribute' do
      u = AdminUser.new(id: 1)
      expect(u.id).to eq(1)
      expect(u.special_id).to eq(1)

      u.id = 2
      expect(u.id).to eq(2)
      expect(u.special_id).to eq(2)

      expect(u.attributes).to include(special_id: 2)
    end
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

  describe '.find(id)' do
    it 'responds to the method' do
      expect(User.respond_to?(:find)).to eq(true)
    end
  end

  describe '.create(attributes)' do
    it 'responds to the method' do
      expect(User.respond_to?(:create)).to eq(true)
    end
  end

  describe '.all' do
    it 'returns a Relation' do
      expect(User.all).to be_a(Drowsy::Relation)
    end
  end

  describe '.where(conditions)' do
    it 'delegates to Relation' do
      expect(User.where(Hash.new)).to be_a(Drowsy::Relation)
    end
  end

  describe 'class definition methods' do
    describe '.attributes(names)' do
      before do
        klass = Class.new(Drowsy::Model) do
          self.uri = '/users{/id}'
          self.connection = C
        end

        stub_const('TestUser', klass)
      end

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
      it 'includes attributes from .attributes setup' do
        expect(User.known_attributes).to contain_exactly(:name)
      end

      context 'for an inherited model' do
        it 'includes attributes from parent and child' do
          expect(AdminUser.known_attributes).to contain_exactly(:special_id, :role, :name)
        end
      end
    end

    describe '.primary_key/primary_key=' do
      before do
        klass = Class.new(Drowsy::Model) do
          self.uri = '/users{/id}'
          self.connection = C
        end

        stub_const('TestUser', klass)
      end

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
