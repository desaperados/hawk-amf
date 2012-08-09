require 'action_controller/railtie'

Mime::Type.register "application/x-amf", :amf

module ActionController
  module Renderers
    attr_reader :amf_response

    add :amf do |amf, options|
      @amf_response = amf.is_a?(ActiveRecord::Relation) ? amf.to_a : amf
      self.content_type ||= Mime::AMF
      self.response_body = " "
    end
  end
end

module HawkAMF
  # Rails controller extensions to access AMF information.
  module Controller

    # Returns whether or not the request is an AMF request
    def is_amf?
      @is_amf == true
    end
    alias_method :is_amf, :is_amf?
  end
end