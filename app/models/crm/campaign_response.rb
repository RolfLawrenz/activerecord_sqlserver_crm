module Crm
  class CampaignResponse < ActiveRecord::Base
    self.table_name = "CampaignResponse"
    self.primary_key = "ActivityId"

    has_many :activity_parties, foreign_key: 'PartyId'
    has_many :notes, foreign_key: 'ObjectId'

  end
end