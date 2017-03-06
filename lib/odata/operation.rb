require 'typhoeus'

module OData
  class Operation

    attr_accessor :ar

    def initialize(ar)
      @ar = ar
    end

    def base_url
      OdataConfig.odata_config[Rails.env]['data_url']
    end

    def old_base_url
      OdataConfig.odata_config[Rails.env]['old_data_url']
    end

    def check_response_errors(response)
      # Check for Http error
      if response.code.to_i >= 400
        error_message = begin
          JSON.parse(response.body)['error']['message']
        rescue
          "An error occurred"
        end
        @ar.errors[:base] << "#{error_message} [http code #{response.code}]"
      end
    end

    def entity_name
      @ar.class.odata_table_reference || table_pluralize(@ar.class.table_name).downcase
    end

    def handle_operation_response(response)
      raise NotImplementedError
    end

    def many_to_many_table?
      @ar.class.many_to_many_associated_tables.present?
    end

    def many_to_many_use_old_api?
      @ar.class.many_to_many_use_old_api
    end

    def many_to_many_binding_name
      @ar.class.many_to_many_binding_name || many_to_many_table_name
    end

    def many_to_many_entity_name(index)
      @ar.class.many_to_many_associated_tables[index].odata_table_reference || table_pluralize(many_to_many_associated_table_name(index)).downcase
    end

    def many_to_many_class_name(index)
      @ar.class.many_to_many_associated_tables[index].name.demodulize.underscore
    end

    def many_to_many_entity_id(index)
      @ar.send(many_to_many_class_name(index)).id
    end

    def many_to_many_foreign_key(index)
      @ar.class.belongs_to_field_by_name(many_to_many_class_name(index)).foreign_key
    end

    def many_to_many_table_name
      @ar.class.odata_table_reference || @ar.class.table_name
    end

    def many_to_many_associated_table_name(index)
      @ar.class.many_to_many_associated_tables[index].table_name
    end

    def operation_body
      nil
    end

    def operation_callback_name
      raise NotImplementedError
    end

    def operation_headers
      {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json; charset=utf-8',
          'OData-MaxVersion' => '4.0',
          'OData-Version' => '4.0'
      }
    end

    def operation_method
      raise NotImplementedError
    end

    def operation_password
      OdataConfig.odata_config[Rails.env]['password']
    end

    def operation_url
      raise NotImplementedError
    end

    def operation_username
      OdataConfig.odata_config[Rails.env]['username']
    end

    def table_pluralize(name)
      name.end_with?('s') ? "#{name}es" : name.pluralize
    end

    def run
      response = send_odata
      handle_operation_response(response)
    end

    def saved_many_to_many_id
      @ar.class.where("#{many_to_many_foreign_key(0)} = '#{many_to_many_entity_id(0)}' AND #{many_to_many_foreign_key(1)} = '#{many_to_many_entity_id(1)}'").first.id
    end

    def send_odata
      @ar.run_callbacks operation_callback_name do
        if Rails.env.development? || Rails.env.test? || Rails.env.staging?
          Rails.logger.debug "SEND_ODATA URL: #{operation_url}"
          Rails.logger.debug "SEND_ODATA METHOD: #{operation_method}"
          Rails.logger.debug "SEND_ODATA BODY: #{operation_body}"
        end
        request = ::Typhoeus::Request.new(
            operation_url,
            method: operation_method,
            body: operation_body,
            headers: operation_headers,
            username: operation_username,
            password: operation_password,
            httpauth: :ntlm
        )
        request.run
      end
    end

  end
end