require 'rocketamf'
require 'rails'

require 'hawk-amf/serialization'
require 'hawk-amf/action_controller'
require 'hawk-amf/configuration'
require 'hawk-amf/request_parser'
require 'hawk-amf/request_processor'

module HawkAMF
  class Railtie < Rails::Railtie
    config.hawkamf = HawkAMF::Configuration.new

    initializer "hawkamf.middleware" do
      config.app_middleware.use HawkAMF::RequestParser, config.hawkamf, Rails.logger
      config.app_middleware.use HawkAMF::RequestProcessor, config.hawkamf, Rails.logger
    end
  end
end
