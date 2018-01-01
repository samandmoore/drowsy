require 'multi_json'

class Drowsy::JsonParser < Faraday::Response::Middleware
  DEFAULT_RESPONSE = '{}'.freeze

  def parse(body)
    body = DEFAULT_RESPONSE if body.blank?
    json = MultiJson.load(body, symbolize_keys: true)
    errors = json.delete(:errors) if json.is_a? Hash
    {
      data: json,
      errors: errors
    }
  end
end
