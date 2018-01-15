require 'spec_helper'

RSpec.describe Drowsy::Http do
  describe '#request' do
    it 'makes get requests'
    it 'makes post requests'
    it 'makes put requests'
    it 'makes patch requests'
    it 'makes delete requests'
    it 'supports open timeout option'
    it 'supports read timeout option'
    it 'raises a Drowsy::ConnectionError for faraday connection errors'
    it 'raises a Drowsy::UnauthorizedError for 401'
    it 'raises a Drowsy::ForbiddenError for 403'
    it 'raises a Drowsy::ResourceNotFound for 404'
    it 'raises a Drowsy::ResourceInvalid for 422'
    it 'raises a Drowsy::ClientError for other 4xx'
    it 'raises a Drowsy::ServerError for 5xx'
    it 'raises a Drowsy::UnknownResponseError for anything else'
  end
end
