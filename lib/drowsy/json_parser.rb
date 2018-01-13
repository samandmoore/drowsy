require 'faraday'
require 'multi_json'

class Drowsy::JsonParser < Faraday::Response::Middleware
  DEFAULT_RESPONSE = '{}'.freeze

  def on_complete(env)
    if env.parse_body? && json_response?(env)
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
    content_type = env.response_headers['content-type']
    content_type && (content_type =~ /\bjson\z/) > -1
  end
end
