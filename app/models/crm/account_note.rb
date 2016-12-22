module Crm
  class AccountNote < Note
    belongs_to :account, foreign_key: 'ObjectId', crm_key: 'objectid_account'
  end
end
