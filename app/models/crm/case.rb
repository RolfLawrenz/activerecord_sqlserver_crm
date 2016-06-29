module Crm
  class Case < ActiveRecord::Base
    self.table_name = "Incident"
    self.primary_key = "IncidentId"

    belongs_to :contact, foreign_key: 'ContactId', crm_key: 'customerid_contact'
    belongs_to :account, foreign_key: 'AccountId', crm_key: 'customerid_account'

    has_many :notes, foreign_key: 'ObjectId'

  end
end
