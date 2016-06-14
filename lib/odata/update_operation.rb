module OData
  class UpdateOperation < CreateOperation

    def operation_method
      :patch
    end

    def operation_callback_name
      :update
    end

    def operation_url
      "#{base_url}#{entity_name}(#{@ar.id})"
    end

  end
end