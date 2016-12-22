module Crm
  class CampaignResponseNote < Note
    belongs_to :campaign_response, foreign_key: 'ObjectId', crm_key: 'objectid_campaignresponse'
  end
end
