module Crm
  class CaseNote < Note
    belongs_to :case, foreign_key: 'ObjectId', crm_key: 'objectid_case'
  end
end
