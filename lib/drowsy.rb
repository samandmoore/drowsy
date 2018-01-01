require 'drowsy/version'
require 'active_support'
require 'active_support/core_ext'
require 'faraday'
require 'faraday_middleware'

module Drowsy
end

require 'drowsy/errors'
require 'drowsy/json_parser'
require 'drowsy/http'
require 'drowsy/uri'
require 'drowsy/relation'
require 'drowsy/scoping'
require 'drowsy/model'
