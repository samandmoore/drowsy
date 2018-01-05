require 'faraday'
require 'multi_json'

class Drowsy::JsonParser < Faraday::Response::Middleware
  DEFAULT_RESPONSE = '{}'.freeze

  def on_complete(env)
    if json_response?(env) && env.parse_body?
      env.body = parse_body(env.body)
    end
  end

  def parse_body(raw_body)
    json = MultiJson.load(parseable_body(raw_body), symbolize_keys: true)
    errors = json.delete(:errors) if json.is_a? Hash
    {
      data: json,
      errors: errors
    }
  end

  def parseable_body(raw_body)
    if raw_body.blank?
      DEFAULT_RESPONSE
    else
      raw_body
    end
  end

  def json_response?(env)
    (env.response_headers['content-type'] =~ /\bjson\z/) > -1
  end
end
