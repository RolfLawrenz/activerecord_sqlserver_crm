module Crm
  class PriceList < ActiveRecord::Base
    self.table_name = "PriceLevel"
    self.primary_key = "PriceLevelId"

    belongs_to :currency, foreign_key: 'TransactionCurrencyId', crm_key: 'transactioncurrencyid'

    has_many :invoices, foreign_key: 'PriceLevelId'
    has_many :price_list_items, foreign_key: 'PriceLevelId'
    has_many :products, foreign_key: 'PriceLevelId'

    validates :Name, presence: true
    validates :currency, presence: true

  end
end
