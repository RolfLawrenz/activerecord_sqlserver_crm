module Crm
  class ContactNote < Note
    belongs_to :contact, foreign_key: 'ObjectId', crm_key: 'objectid_contact'
  end
end
