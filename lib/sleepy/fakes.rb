require 'webmock'
require 'sinatra/base'
require 'sinatra/json'

class FakeJsonApi < Sinatra::Base
  set :dump_errors, false
  set :show_exceptions, false
  set :raise_errors, true

  get '/posts' do
    json(
      [
        { title: 'One' },
        { title: 'Two' }
      ]
    )
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


H = Sleepy::Http.new(Faraday.new(url: 'https://test.dev') do |c|
  c.request   :json
  c.use       Sleepy::JsonParser
  c.adapter   Faraday.default_adapter
end)
