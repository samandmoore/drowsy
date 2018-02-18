require 'spec_helper'

RSpec.describe 'Drowsy::Relation custom http' do
  before do
    define_model('TestUser', uri: '/users{/id}') do
      attributes :name
    end
  end

  describe '#get' do
    it 'performs a GET'
    it 'adds additional params to querystring'
    it 'adds symbol to uri'
    it 'uses string as url'
  end

  describe '#post' do
    it 'performs a POST'
    it 'adds additional params to body'
    it 'adds symbol to uri'
    it 'uses string as url'
  end

  describe '#put' do
    it 'performs a PUT'
    it 'adds additional params to body'
    it 'adds symbol to uri'
    it 'uses string as url'
  end

  describe '#patch' do
    it 'performs a PATCH'
    it 'adds additional params to body'
    it 'adds symbol to uri'
    it 'uses string as url'
  end

  describe '#delete' do
    it 'performs a DELETE'
    it 'adds additional params to body'
    it 'adds symbol to uri'
    it 'uses string as url'
  end
end
