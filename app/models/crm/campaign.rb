module Crm
  class Campaign < ActiveRecord::Base
    self.table_name = "Campaign"
    self.primary_key = "CampaignId"

    has_many :notes, foreign_key: 'ObjectId'

  end
end
