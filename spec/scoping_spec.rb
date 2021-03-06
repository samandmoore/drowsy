require 'spec_helper'

RSpec.describe 'Scopes' do
  before do
    define_model('TestUser', uri: '/users{/id}') do
      attributes :name
    end
  end

  describe '.scope' do
    it 'defines a method on the class' do
      TestUser.scope :with_name, ->(name) { where(name: name) }
      expect(TestUser.with_name('foo').params).to include name: 'foo'
      expect(TestUser.all.with_name('foo').params).to include name: 'foo'
    end

    it 'makes the corresponding relation responds to the scope name' do
      TestUser.scope :with_name, ->(name) { where(name: name) }
      expect(TestUser.all.with_name('foo').params).to include name: 'foo'
    end

    it 'creates a method that can be chained off of' do
      TestUser.scope :with_name, ->(name) { where(name: name) }
      expect(TestUser.with_name('foo').where(something_else: 1).params).to include name: 'foo', something_else: 1
    end

    specify 'scopes defined on child classes do not end up on parent' do
      define_model('TestChildUser', parent_klass: TestUser, uri: '/child_users{/id}')
      TestChildUser.scope :with_name, ->(name) { where(name: name) }

      expect(TestChildUser.respond_to?(:with_name)).to eq true
      expect(TestUser.respond_to?(:with_name)).not_to eq true
    end

    specify 'scopes are inherited' do
      define_model('TestChildUser', parent_klass: TestUser, uri: '/child_users{/id}')
      TestUser.scope :with_name, ->(name) { where(name: name) }

      expect(TestChildUser.respond_to?(:with_name)).to eq true
    end
  end
end
