module Crm
  class OpportunityNote < Note
    belongs_to :opportunity, foreign_key: 'ObjectId', crm_key: 'objectid_opportunity'
  end
end
