require 'rocketamf'
require 'rails'

require 'hawk-amf/serialization'
require 'hawk-amf/action_controller'
require 'hawk-amf/configuration'
require 'hawk-amf/request_parser'
require 'hawk-amf/request_processor'
require 'hawk-amf/fault'

ActionController::Base.send(:include, HawkAMF::Controller)

# The new query interface in rails 3 returns an ActiveRecord::Relation object 
# instead of Array. If you try to pass this directly to the renderer it results 
# in a LocalJumpError (no block given) error that can be traced back to the generic 
# object serializer in RocketAMF (ClassMapping#props_for_serialization).
# Ensure that we properly serialize ActiveRecord::Relation in all cases
class ActiveRecord::Relation	
  def encode_amf ser
    ser.serialize ser.version, self.to_a
  end
end

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
