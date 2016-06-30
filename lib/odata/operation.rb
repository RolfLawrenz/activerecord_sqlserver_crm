require 'typhoeus'

module OData
  class Operation

    attr_accessor :ar

    def initialize(ar)
      @ar = ar
    end

    def base_url
      ODATA_CONFIG[Rails.env]['data_url']
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
      table_pluralize(@ar.class.table_name).downcase
    end

    def handle_operation_response(response)
      raise NotImplementedError
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
          'Content-Type' => 'application/json; charset=utf-8'
      }
    end

    def operation_method
      raise NotImplementedError
    end

    def operation_password
      ODATA_CONFIG[Rails.env]['password']
    end

    def operation_url
      raise NotImplementedError
    end

    def operation_username
      ODATA_CONFIG[Rails.env]['username']
    end

    def table_pluralize(name)
      name.end_with?('s') ? "#{name}es" : name.pluralize
    end

    def run
      response = send_odata
      handle_operation_response(response)
    end

    def send_odata
      @ar.run_callbacks operation_callback_name do
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