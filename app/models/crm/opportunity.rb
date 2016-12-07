module Crm
  class Opportunity < ActiveRecord::Base
    self.table_name = "Opportunity"
    self.primary_key = "OpportunityId"

    belongs_to :campaign, foreign_key: 'CampaignId', crm_key: 'campaignid'
    belongs_to :contact, foreign_key: 'contactid', crm_key: 'parentcontactid'

    has_many :invoices, foreign_key: 'OpportunityId'
    has_many :notes, foreign_key: 'ObjectId'

  end
end