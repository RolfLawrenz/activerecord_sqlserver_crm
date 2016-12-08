module Crm
  class Opportunity < ActiveRecord::Base
    self.table_name = "Opportunity"
    self.primary_key = "OpportunityId"

    belongs_to :campaign, foreign_key: 'CampaignId', crm_key: 'campaignid'
    belongs_to :account, foreign_key: 'AccountId', crm_key: 'customerid_account'
    belongs_to :contact, foreign_key: 'ContactId', crm_key: 'customerid_contact'
    belongs_to :parent_account, foreign_key: 'ParentAccountId', crm_key: 'parentaccountid', class_name: 'Crm::Account'
    belongs_to :parent_contact, foreign_key: 'ParentContactId', crm_key: 'parentcontactid', class_name: 'Crm::Contact'

    has_many :invoices, foreign_key: 'OpportunityId'
    has_many :notes, foreign_key: 'ObjectId'

  end
end