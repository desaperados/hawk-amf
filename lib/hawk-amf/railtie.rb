require 'rocketamf'
require 'rails'

require 'hawk-amf/serialization'
require 'hawk-amf/action_controller'
require 'hawk-amf/configuration'
require 'hawk-amf/request_parser'
require 'hawk-amf/request_processor'
require 'hawk-amf/fault'

ActionController::Base.send(:include, HawkAMF::Controller)

module HawkAMF
  class Railtie < Rails::Railtie
    
    config.hawkamf = HawkAMF::Configuration.new
    
    initializer "rubyamf.configured" do
      RocketAMF::ClassMapper.use_array_collection = HawkAMF::Configuration.use_array_collection
      RocketAMF::ClassMapper.translate_case = HawkAMF::Configuration.translate_case
    end

    initializer "hawkamf.middleware" do
      config.app_middleware.use HawkAMF::RequestParser, config.hawkamf, Rails.logger
      config.app_middleware.use HawkAMF::RequestProcessor, config.hawkamf, Rails.logger
    end
  end
end
