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
      "#{base_url}#{entity_name}(#{@ar.id})"
    end
  end
end