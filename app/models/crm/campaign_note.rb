module Crm
  class CampaignNote < Note
    belongs_to :campaign, foreign_key: 'ObjectId', crm_key: 'objectid_campaign'
  end
end
