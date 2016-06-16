module Crm
  class CampaignResponse < ActiveRecord::Base
    self.table_name = "CampaignResponse"
    self.primary_key = "ActivityId"

    has_many :notes, foreign_key: 'ObjectId'

  end
end