require 'spec_helper'

RSpec.describe Drowsy::Relation do
  before do
    define_model('TestUser', uri: '/users{/id}') do
      attributes :name
    end
  end

  describe '.all' do
    it 'makes a GET request to class URI when enumerated' do
      stub_request(:get, 'https://fake.test/users')
        .to_return(body: [{ id: 1, name: 'foo' }].to_json, headers: { 'content-type': 'application/json' })

      result = TestUser.all.to_a

      expect(result).to contain_exactly(TestUser.new(id: 1, name: 'foo'))

      expect(WebMock).to have_requested(:get, 'https://fake.test/users')
    end
  end

  describe '.where(conditions)' do
    it 'collects the provided params and includes them in the GET request' do
      stub_request(:get, 'https://fake.test/users?name=foo')
        .to_return(body: [].to_json, headers: { 'content-type': 'application/json' })

      result = TestUser.all.where(name: 'foo').to_a

      expect(WebMock).to have_requested(:get, 'https://fake.test/users?name=foo')
    end
  end

  describe '.find(id)' do
    it 'makes a GET request with the id' do
      stub_request(:get, 'https://fake.test/users/123')
        .to_return(body: {}.to_json, headers: { 'content-type': 'application/json' })

      TestUser.find(123)

      expect(WebMock).to have_requested(:get, 'https://fake.test/users/123')
    end

    it 'includes where clause params in request' do
      stub_request(:get, 'https://fake.test/users/123?name=foo&bar=true')
        .to_return(body: {}.to_json, headers: { 'content-type': 'application/json' })

      TestUser.where(name: 'foo').where(bar: true).find(123)

      expect(WebMock).to have_requested(:get, 'https://fake.test/users/123?name=foo&bar=true')
    end

    it 'raises on 404s' do
      stub_request(:get, 'https://fake.test/users/123')
        .to_return(status: 404, headers: { 'content-type': 'application/json' })

      expect { TestUser.find(123) }.to raise_error(Drowsy::ResourceNotFound, /Request Failed\.  HTTP status code:  404\./)

      expect(WebMock).to have_requested(:get, 'https://fake.test/users/123')
    end
  end

  describe '.find_by(attributes)' do
    it 'includes all params in GET request' do
      stub_request(:get, 'https://fake.test/users/123?name=foo')
        .to_return(body: {}.to_json, headers: { 'content-type': 'application/json' })

      TestUser.find_by(id: 123, name: 'foo')

      expect(WebMock).to have_requested(:get, 'https://fake.test/users/123?name=foo')
    end

    it 'works without an id param' do
      stub_request(:get, 'https://fake.test/users?name=foo')
        .to_return(body: [].to_json, headers: { 'content-type': 'application/json' })

      TestUser.find_by(name: 'foo')

      expect(WebMock).to have_requested(:get, 'https://fake.test/users?name=foo')
    end

    it 'always return a single result' do
      stub_request(:get, 'https://fake.test/users?name=foo')
        .to_return(body: [ {id: 1}, {id: 2} ].to_json, headers: { 'content-type': 'application/json' })

      expect(TestUser.find_by(name: 'foo')).to eq(TestUser.new(id: 1))

      expect(WebMock).to have_requested(:get, 'https://fake.test/users?name=foo')
    end

    it 'returns nil on 404s' do
      stub_request(:get, 'https://fake.test/users/123')
        .to_return(status: 404, headers: { 'content-type': 'application/json' })

      expect(TestUser.find_by(id: 123)).to be_nil

      expect(WebMock).to have_requested(:get, 'https://fake.test/users/123')
    end
  end

  describe '.find_by!(attributes)' do
    it 'raises on 404s' do
      stub_request(:get, 'https://fake.test/users/123')
        .to_return(status: 404, headers: { 'content-type': 'application/json' })

      expect { TestUser.find_by!(id: 123) }.to raise_error(Drowsy::ResourceNotFound, /Request Failed\.  HTTP status code:  404\./)

      expect(WebMock).to have_requested(:get, 'https://fake.test/users/123')
    end
  end

  describe '.build(attributes)' do
    it 'builds a new instance of the underlying type' do
      expect(TestUser.all.build(name: 'foo')).to be_a(TestUser)
      expect(TestUser.all.build(name: 'foo').attributes).to match(id: nil, name: 'foo')
    end

    it 'includes all where clause params in the built instance' do
      expect(TestUser.where(name: 'foo').build.attributes).to match(id: nil, name: 'foo')
    end
  end

  describe '.create(attributes)' do
    it 'builds a new instance of the underlying type, saves it, and returns it' do
      stub_request(:post, 'https://fake.test/users')
        .to_return(body: { id: 123 }.to_json, headers: { 'content-type': 'application/json' })

      expect(TestUser.create(name: 'foo')).to eq(TestUser.new(id: 123, name: 'foo'))
    end
  end

  describe '.create!(attributes)' do
    it 'raises on local validation errors' do
      TestUser.class_eval do
        validates :name, presence: true
      end

      expect { TestUser.create! }.to raise_error(Drowsy::ModelInvalid, /Name can't be blank/)
    end

    it 'raises on remote validation errors' do
      stub_request(:post, 'https://fake.test/users')
        .to_return(
            status: 422,
            body: {"errors":{"name":[{"error":"blank","message":"can't be blank"}]}}.to_json,
            headers: { 'content-type': 'application/json' }
        )

      expect { TestUser.create! }.to raise_error(Drowsy::ModelInvalid, /Name can't be blank/)
    end
  end
end
