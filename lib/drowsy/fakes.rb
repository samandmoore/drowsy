require 'webmock'
require 'sinatra/base'
require 'sinatra/json'

C = Faraday.new(url: 'https://test.dev') do |c|
  c.request   :json
  c.use       Drowsy::JsonParser
  c.response  :logger, nil, bodies: true
  c.adapter   Faraday.default_adapter
end
H = Drowsy::Http.new(C)

class User < Drowsy::Model
  self.uri = '/users{/id}'
  self.connection = C
  has_many :posts
  attributes :name
end

class Post < Drowsy::Model
  self.uri = '/posts{/id}'
  self.connection = C
  belongs_to :user
  attributes :title
end

class FakeJsonApi < Sinatra::Base
  set :dump_errors, false
  set :show_exceptions, false
  set :raise_errors, true

  get '/users' do
    json(
      [
        build_user,
        build_user,
        build_user
      ]
    )
  end

  get '/posts' do
    json(
      [
        build_post,
        build_post,
        build_post
      ]
    )
  end

  get '/posts/:id' do
    json(
      build_post(id: params['id'])
    )
  end

  put '/posts/:id' do
    data = MultiJson.load(request.body)
    if data['title']
      json(
        id: params['id'], title: data['title']
      )
    else
      status 422
      json(
        errors: {
          title: [
            { error: 'blank', message: 'can\'t be blank' },
          ]
        }
      )
    end
  end

  post '/posts' do
    data = MultiJson.load(request.body)
    if data['title']
      json(
        id: rand(1..1000), title: data['title']
      )
    else
      status 422
      json(
        errors: {
          title: [
            { error: 'blank', message: 'can\'t be blank' },
          ]
        }
      )
    end
  end

  delete '/posts/:id' do
    status 204
  end

  def build_post(id: rand(1..1000), user_id: rand(1..1000))
    { id: id, title: "Post #{id}", user_id: user_id, junk: "junk" }
  end

  def build_user(id: rand(1..1000))
    { id: id, name: "User #{id}", posts: [build_post(user_id: id), build_post(user_id: id)] }
  end

  %w(get post put patch delete).each do |method|
    return_block = Proc.new { status(params[:return_status]) }
    send(method, '/:return_status', &return_block)
  end

  private

  def route_missing
    raise "route not defined for #{request.request_method} #{uri} in #{self.class.name}."
  end
end

WebMock.enable!
WebMock.disable_net_connect!
WebMock.stub_request(
  :any,
  /\Ahttps:\/\/test\.dev/
).to_rack(FakeJsonApi.new)
