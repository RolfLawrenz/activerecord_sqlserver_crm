module Crm
  class PriceListItem < ActiveRecord::Base
    self.table_name = "ProductPriceLevel"
    self.primary_key = "ProductPriceLevelId"

    belongs_to :price_list, foreign_key: 'PriceLevelId', crm_key: 'pricelevelid'
    belongs_to :product, foreign_key: 'ProductId', crm_key: 'productid'
    belongs_to :uom, foreign_key: 'UoMId', crm_key: 'uomid'
    belongs_to :currency, foreign_key: 'TransactionCurrencyId', crm_key: 'transactioncurrencyid'

    validates :Amount, presence: true
    validates :price_list, presence: true
    validates :product, presence: true
    validates :uom, presence: true

  end
end
