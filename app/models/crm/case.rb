module Crm
  class Case < ActiveRecord::Base
    self.table_name = "Incident"
    self.primary_key = "IncidentId"

    belongs_to :contact, foreign_key: 'IncidentId', crm_key: 'customerid_contact'
    belongs_to :account, foreign_key: 'IncidentId', crm_key: 'customerid_account'

    has_many :activity_parties, foreign_key: 'PartyId'
    has_many :notes, foreign_key: 'ObjectId'

  end
end
