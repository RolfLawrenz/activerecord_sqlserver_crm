# This is treated as an abstract class. We cant use the same objectId as a foreign key for each Entity Type.
# To get around this issue we create a Note type for each Entity type. Each EntityNote contains only a single
# entry for the ObjectId.
module Crm
  class Note < ::ApplicationRecord
    self.table_name = "Annotation"
    self.primary_key = "AnnotationId"

    # *** Dont add ObjectIds here. Foreign Keys must be unique

    validates :Subject, presence: true

  end
end
