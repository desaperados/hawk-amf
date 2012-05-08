module HawkAMF
  module Deprecated
    
    def as_class class_name
      msg = <<-eos
      -------------------------------------------------------------
        [HawkAMF] Setting as_class on the model is no longer valid
        
        #{self.name}
        as_class #{class_name}
        
        ActionScript class mappings should be defined in config
      eos
      logger.warn msg
    end
    
    def map_amf scope_or_options=nil, options=nil
      msg = <<-eos
      --------------------------------------------------------------
        [HawkAMF] Calling map_amf on your model is no longer valid
        
        Use to_amf instead in #{self.name}
      eos
      logger.warn msg
    end
    
  end
end