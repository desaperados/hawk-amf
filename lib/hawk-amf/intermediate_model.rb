module HawkAMF
  class IntermediateModel
    TRAIT_CACHE = {}

    def initialize model, props
      @model = model
      @props = props.inject({}) {|out, (k,v)| out[k.to_s] = v; out}
    end

    def encode_amf serializer
      if serializer.version == 0
        serializer.write_object @model, @props
      elsif serializer.version == 3
        # Use traits to reduce overhead
        unless traits = TRAIT_CACHE[@model.class]
          # Auto-map class name if enabled
          class_name = RocketAMF::ClassMapper.new.get_as_class_name(@model)
          
          ::Rails.logger.debug "[HawkAMF::IntermediateModel] Ruby Class: #{@model.class.name} AS Class: #{class_name}"
          
          if HawkAMF::Configuration.auto_class_mapping && class_name.nil?
            class_name = @model.class.name
            RocketAMF::ClassMapper.define {|m| m.map :as => class_name, :rb => class_name}
          end

          # For now use dynamic traits...
          # members must be symbols in Ruby 1.9 and strings in Ruby 1.8
          traits = {
            :class_name => class_name,
            :members => [],
            :externalizable => false,
            :dynamic => true
          }
          TRAIT_CACHE[@model.class] = traits
        end
        ::Rails.logger.debug "[RocketAMF] serializing #{@model.class.name}"
        begin
          serializer.write_object @model, @props, traits
        rescue Exception => e
          # Log and re-raise exception
          ::Rails.logger.error e.to_s+"\n"+e.backtrace.join("\n")
          raise e
        end
      end
    end
  end
end