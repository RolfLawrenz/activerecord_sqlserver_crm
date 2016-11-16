module Crm
  class Note < ActiveRecord::Base
    self.table_name = "Annotation"
    self.primary_key = "AnnotationId"

    belongs_to :account, foreign_key: 'ObjectId', crm_key: 'objectid_account'
    belongs_to :campaign, foreign_key: 'ObjectId', crm_key: 'objectid_campaign'
    belongs_to :campaign_response, foreign_key: 'ObjectId', crm_key: 'objectid_campaignresponse'
    belongs_to :case, foreign_key: 'ObjectId', crm_key: 'objectid_case'
    belongs_to :contact, foreign_key: 'ObjectId', crm_key: 'objectid_contact'
    belongs_to :invoice, foreign_key: 'ObjectId', crm_key: 'objectid_invoice'

    validates :Subject, presence: true

  end
end
