module Crm
  class Campaign < ::ApplicationRecord
    self.table_name = "Campaign"
    self.primary_key = "CampaignId"

    belongs_to :currency, foreign_key: 'TransactionCurrencyId', crm_key: 'transactioncurrencyid'

    has_many :notes, foreign_key: 'ObjectId', class_name: "Crm::CampaignNote"
    has_many :campaign_responses, foreign_key: 'RegardingObjectId'

    validates :Name, presence: true
    validates :currency, presence: true
  end
end
