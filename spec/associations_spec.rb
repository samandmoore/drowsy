require 'spec_helper'

RSpec.describe 'Association behavior' do
  describe 'has many' do
    describe 'default behavior' do
      before do
        define_model('TestUser', uri: '/users{/id}') do
          attributes :name
          has_many :test_posts
        end

        define_model('TestPost', uri: '/posts{/id}') do
          attributes :title
          belongs_to :test_user
        end
      end

      it 'maps embedded documents to typed association objects' do
        stub_request(:get, 'https://fake.test/users/1')
          .to_return(
            headers: { 'content-type': 'application/json' },
            body: [
              { id: 1, name: 'foo', test_posts: [{ id: 'deadbeef', title: 'good post' }] }
            ].to_json
        )

        result = TestUser.find(1)
        expect(result.test_posts.size).to eq(1)
        expect(result.test_posts.first).to be_a(TestPost)
        expect(result.test_posts.first.attributes).to match(id: 'deadbeef', title: 'good post', test_user_id: 1)
      end

      it 'sets the corresponding belongs to inverse association' do
        stub_request(:get, 'https://fake.test/users/1')
          .to_return(
            headers: { 'content-type': 'application/json' },
            body: [
              { id: 1, name: 'foo', test_posts: [{ id: 'deadbeef', title: 'good post' }] }
            ].to_json
        )

        result = TestUser.find(1)
        expect(result.test_posts.first.test_user).to eq(result)
      end
    end

    it 'respects class_name option' do
      define_model('TestSpecialUser', uri: '/users{/id}') do
        attributes :name
        has_many :posts, class_name: 'TestSpecialPost'
      end

      define_model('TestSpecialPost', uri: '/posts{/id}') do
        attributes :title
        belongs_to :test_special_user
      end

      stub_request(:get, 'https://fake.test/users/1')
        .to_return(
          headers: { 'content-type': 'application/json' },
          body: [
            { id: 1, name: 'foo', posts: [{ id: 'deadbeef', title: 'good post' }] }
          ].to_json
        )

      result = TestSpecialUser.find(1)
      expect(result.posts.first).to be_a(TestSpecialPost)
      expect(result.posts.first.attributes).to match(id: 'deadbeef', title: 'good post', test_special_user_id: 1)
    end

    it 'respects the inverse_of option' do
      define_model('TestUser', uri: '/users{/id}') do
        attributes :name
        has_many :test_posts, inverse_of: :user
      end

      define_model('TestPost', uri: '/posts{/id}') do
        attributes :title
        belongs_to :user, class_name: 'TestUser'
      end

      stub_request(:get, 'https://fake.test/users/1')
        .to_return(
          headers: { 'content-type': 'application/json' },
          body: [
            { id: 1, name: 'foo', test_posts: [{ id: 'deadbeef', title: 'good post' }] }
          ].to_json
        )

      result = TestUser.find(1)
      expect(result.test_posts.first).to be_a(TestPost)
      expect(result.test_posts.first.user).to eq(result)
      expect(result.test_posts.first.attributes).to match(id: 'deadbeef', title: 'good post', user_id: 1)
    end

    it 'provides a build method for the association'
    it 'returns a proxy for unfetched instances'
    it 'allows assignment of an array of association types'
  end

  # TODO: these tests are basically the same as the has_many tests
  # it might be better to just test the behavior of fetching a Post
  # that belongs to a user and showing what the intended behavior is
  describe 'belongs to' do
    it 'respects the inverse_of option' do
      define_model('TestUser', uri: '/users{/id}') do
        attributes :name
        has_many :posts, class_name: 'TestPost'
      end

      define_model('TestPost', uri: '/posts{/id}') do
        attributes :title
        belongs_to :test_user, inverse_of: :posts
      end

      stub_request(:get, 'https://fake.test/users/1')
        .to_return(
          headers: { 'content-type': 'application/json' },
          body: [
            { id: 1, name: 'foo', posts: [{ id: 'deadbeef', title: 'good post' }] }
          ].to_json
        )

      result = TestUser.find(1)
      expect(result.posts.first).to be_a(TestPost)
      expect(result.posts.first.test_user).to eq(result)
      expect(result.posts.first.attributes).to match(id: 'deadbeef', title: 'good post', test_user_id: 1)
    end

    it 'respects the class_name option' do
      define_model('TestUser', uri: '/users{/id}') do
        attributes :name
        has_many :test_posts, inverse_of: :user
      end

      define_model('TestPost', uri: '/posts{/id}') do
        attributes :title
        belongs_to :user, class_name: 'TestUser'
      end

      stub_request(:get, 'https://fake.test/users/1')
        .to_return(
          headers: { 'content-type': 'application/json' },
          body: [
            { id: 1, name: 'foo', test_posts: [{ id: 'deadbeef', title: 'good post' }] }
          ].to_json
        )

      result = TestUser.find(1)
      expect(result.test_posts.first).to be_a(TestPost)
      expect(result.test_posts.first.user).to eq(result)
      expect(result.test_posts.first.attributes).to match(id: 'deadbeef', title: 'good post', user_id: 1)
    end

    it 'provides a build_association_name method for the association'
    it 'allows assignment of an instance of association type'
  end

  describe 'has one' do
    it 'maps embedded documents to typed association objects'
    it 'respects the inverse_of option'
    it 'respects the class_name option'
    it 'provides a build_association_name method for the association'
    it 'allows assignment of an instance of association type'
  end
end
