require 'webmock'
require 'sinatra/base'
require 'sinatra/json'

C = Faraday.new(url: 'https://test.dev') do |c|
  c.request   :json
  c.use       Sleepy::JsonParser
  c.response  :logger, nil, bodies: true
  c.adapter   Faraday.default_adapter
end
H = Sleepy::Http.new(C)

class Post < Sleepy::Model
  self.uri = '/posts{/id}'
  self.connection = C

  attributes :title
end

class FakeJsonApi < Sinatra::Base
  set :dump_errors, false
  set :show_exceptions, false
  set :raise_errors, true

  get '/posts' do
    json(
      [
        build_post(1),
        build_post(2),
        build_post(3)
      ]
    )
  end

  get '/posts/:id' do
    json(
      build_post(params['id'])
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

  def build_post(id)
    { id: id, title: "Post #{id}", junk: "junk" }
  end

  get '/validation_errors' do
    status 422
    json(
      errors: {
        title: [
          { error: 'blank', message: 'can\'t be blank' },
          { error: 'too_short', count: 10, message: 'is too short' }
        ]
      }
    )
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
