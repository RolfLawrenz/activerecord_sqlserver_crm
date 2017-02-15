module OData
  class CreateOperation < Operation

    def handle_operation_response(response)
      # Grab the id, and put back into the active record instance
      if response.headers['OData-EntityId']
        id = response.headers['OData-EntityId'].scan(/\(([\w-]*)\)/)
        @ar.id = id[0][0] unless id.nil? || id[0].nil?
        @ar.errors[:base] << "Failed to #{operation_callback_name} entity. [http code #{response.code}]" if @ar.id.nil?
      elsif response.code >= 200 && response.code < 300
        # Associating record for many to many does not return any body, just a positive response code
        # So look up id and save to attribute
        id = saved_many_to_many_id
        @ar.send("#{@ar.class.primary_key}=".to_sym, id)
      else
        @ar.errors[:base] << "Could not #{operation_callback_name} entity. [http code #{response.code}]" if @ar.id.nil?
      end
      check_response_errors(response)
    end

    def operation_body
      body = {}
      # Add changed fields and values
      @ar.changes.each do |field, values|
        # If a belongs to field, add association the way OData wants it
        if @ar.class.belongs_to_field?(field)
          belongs_to_field = @ar.class.belongs_to_field(field)
          if many_to_many_table?
            if many_to_many_use_old_api?
              body["uri"] = "#{old_base_url}#{many_to_many_associated_table_name(1)}Set(guid%27#{many_to_many_entity_id(1)}%27)"
            else
              body["@odata.id"] = "#{base_url}#{many_to_many_entity_name(1)}(#{many_to_many_entity_id(1)})"
            end
          else
            odata_table_ref = @ar.class.odata_table_reference || table_pluralize(belongs_to_field.table_name).downcase
            body["#{belongs_to_field.options[:crm_key]}@odata.bind"] = "/#{odata_table_ref}(#{values[1]})"
          end
        else
          key = @ar.class.odata_field_value(field.to_sym) || field.downcase
          body[key] = values[1]
        end
      end
      body.to_json
    end

    def operation_method
      :post
    end

    def operation_url
      # For many to many we associate
      if many_to_many_table?
        if many_to_many_use_old_api?
          "#{old_base_url}#{many_to_many_associated_table_name(0)}Set(guid%27#{many_to_many_entity_id(0)}%27)/%24links/#{many_to_many_binding_name}"
        else
          "#{base_url}#{many_to_many_entity_name(0)}(#{many_to_many_entity_id(0)})/#{many_to_many_binding_name}/%24ref"
        end
      else
        "#{base_url}#{entity_name}"
      end
    end

    def operation_callback_name
      :create
    end
  end
end