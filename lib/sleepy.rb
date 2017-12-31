require 'sleepy/version'
require 'active_support'
require 'active_support/core_ext'
require 'faraday'
require 'faraday_middleware'

module Sleepy
end

require 'sleepy/errors'
require 'sleepy/json_parser'
require 'sleepy/http'
require 'sleepy/uri'
require 'sleepy/relation'
require 'sleepy/scoping'
require 'sleepy/model'
