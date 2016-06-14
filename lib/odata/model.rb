require 'odata/operation'
require 'odata/create_operation'
require 'odata/update_operation'
require 'odata/delete_operation'

module OData
  class Model
    def self.save(ar)
      return unless ar.changed?
      operation = ar.new_record? ? OData::CreateOperation.new(ar) : OData::UpdateOperation.new(ar)
      operation.run
      ar
    end

    def self.destroy(ar)
      operation = OData::DeleteOperation.new(ar)
      operation.run
      ar
    end
  end
end
