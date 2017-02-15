module OData
  class DeleteOperation < Operation

    def handle_operation_response(response)
      check_response_errors(response)
    end

    def operation_body
      body = {}
      body.to_json
    end

    def operation_method
      :delete
    end

    def operation_callback_name
      :destroy
    end

    def operation_url
      # For many to many we disassociate
      if many_to_many_table?
        "#{old_base_url}#{many_to_many_associated_table_name(0)}Set(guid%27#{many_to_many_entity_id(0)}%27)/%24links/#{many_to_many_binding_name}(guid%27#{many_to_many_entity_id(1)}%27)"

        # Some reason I cant get the new api to delete, so just using old for now.
        # if many_to_many_use_old_api?
        #   "#{old_base_url}#{many_to_many_associated_table_name(0)}Set(guid%27#{many_to_many_entity_id(0)}%27)/%24links/#{many_to_many_binding_name}(guid%27#{many_to_many_entity_id(1)}%27)"
        # else
        #   "#{base_url}#{many_to_many_entity_name(0)}(#{many_to_many_entity_id(0)})/#{many_to_many_binding_name}/%24ref%3F%24id=#{base_url}#{many_to_many_entity_name(1)}(#{many_to_many_entity_id(1)})"
        # end
      else
        "#{base_url}#{entity_name}(#{@ar.id})"
      end
    end
  end
end