require 'active_model'
require 'hawk-amf/intermediate_model'
require 'hawk-amf/deprecated'

module HawkAMF
  module Serialization
    
    def self.included base #:nodoc:
      base.send :extend, HawkAMF::Deprecated
    end
    
    # Control the serialization of the model by specifying the relations, properties,
    # methods, and other data to serialize with the model. Parameters take the
    # same form as serializable_hash - see active record/active model serialization
    # for more details.
    #
    # If not serialized to an intermediate form before it reaches the AMF
    # serializer, it will be serialized with the default options.
    def to_amf options=nil
      if self.respond_to? :as_amf
        options = as_amf
      end
      # Remove associations so that we can call to_amf on them seperately
      include_associations = options.delete(:include) unless options.nil?

      # Create props hash and serialize relations if supported method available
      props = serializable_hash(options)
      
      ::Rails.logger.debug "[HawkAMF] #{self.class} - to_amf ------------------"
      ::Rails.logger.debug props.inspect
      
      if include_associations
        options[:include] = include_associations
        
        ::Rails.logger.debug "[HawkAMF] #{self.class} - associations -----------"
        ::Rails.logger.debug include_associations.inspect
        
        # Calls to_amf on each of the records being returned with each association
        # association :layers
        # records [array of map layers]
        # opts {:only=>nil, :except=>nil}        
        send(:serializable_add_includes, options) do |association, records, opts|
          props[association] = records.is_a?(Enumerable) ? records.map { |r| r.to_amf(opts) } : records.to_amf(opts)
        end
      end

      # Create wrapper and return
      HawkAMF::IntermediateModel.new(self, props)
    end

    # Called by serialization routines if the user did not use to_amf to convert
    # to an intermediate form prior to serialization. Encodes using the default
    # serialization settings.
    def encode_amf serializer
      self.to_amf.encode_amf serializer
    end
  end
end

# Hook into any object that includes ActiveModel::Serialization
module ActiveModel::Serialization
  include HawkAMF::Serialization
end

# Make ActiveSupport times serialize properly
class ActiveSupport::TimeWithZone
  def encode_amf serializer
    serializer.serialize self.to_datetime
  end
end

# Map array to_amf calls to each element
class Array
  def to_amf options=nil
    self.map {|o| o.to_amf(options)}
  end
end