module Crm
  class Note < ActiveRecord::Base
    self.table_name = "Annotation"
    self.primary_key = "AnnotationId"

    belongs_to :account, foreign_key: 'objectid_account', crm_key: 'Account_Annotation'
    belongs_to :campaign, foreign_key: 'objectid_account', crm_key: 'Campaign_Annotation'
    belongs_to :campaign_response, foreign_key: 'objectid_account', crm_key: 'CampaignResponse_Annotation'
    belongs_to :case, foreign_key: 'objectid_account', crm_key: 'Case_Annotation'
    belongs_to :contact, foreign_key: 'objectid_account', crm_key: 'Contact_Annotation'
    belongs_to :invoice, foreign_key: 'objectid_account', crm_key: 'Invoice_Annotation'

  end
end
