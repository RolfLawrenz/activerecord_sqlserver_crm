module Crm
  class CampaignResponse < ActiveRecord::Base
    self.table_name = "CampaignResponse"
    self.primary_key = "ActivityId"

    belongs_to :campaign, foreign_key: 'RegardingObjectId', crm_key: 'regardingobjectid_campaign_campaignresponse'

    has_many :notes, foreign_key: 'ObjectId', class_name: "Crm::CampaignResponseNote"

    validates :Subject, presence: true
    validates :campaign, presence: true

  end
end