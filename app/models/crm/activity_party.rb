module Crm
  class ActivityParty < ActiveRecord::Base
    self.table_name = "ActivityParty"
    self.primary_key = "ActivityPartyId"

    belongs_to :account, foreign_key: 'PartyId', crm_key: 'account_activity_parties'
    belongs_to :contact, foreign_key: 'PartyId', crm_key: 'contact_activity_parties'
    belongs_to :campaign, foreign_key: 'PartyId', crm_key: 'campaign_activity_parties'
    belongs_to :campaign_response, foreign_key: 'PartyId', crm_key: 'campaign_response_activity_parties'
    belongs_to :case, foreign_key: 'PartyId', crm_key: 'case_activity_parties'
    belongs_to :invoice, foreign_key: 'PartyId', crm_key: 'invoice_activity_parties'

  end
end
