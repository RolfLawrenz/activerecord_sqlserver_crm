module OData
  class CreateOperation < Operation

    def handle_operation_response(response)
      # Grab the id, and put back into the active record instance
      if response.headers['OData-EntityId']
        id = response.headers['OData-EntityId'].scan(/\(([\w-]*)\)/)
        @ar.id = id[0][0] unless id.nil? || id[0].nil?
        @ar.errors[:base] << "Failed to #{operation_callback_name} entity. [http code #{response.code}]" if @ar.id.nil?
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
          odata_table_ref = @ar.class.odata_table_reference || table_pluralize(belongs_to_field.table_name).downcase
          body["#{belongs_to_field.options[:crm_key]}@odata.bind"] = "/#{odata_table_ref}(#{values[1]})"
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
      "#{base_url}#{entity_name}"
    end

    def operation_callback_name
      :create
    end
  end
end