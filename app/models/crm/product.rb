module Crm
  class Product < ActiveRecord::Base
    self.table_name = "Product"
    self.primary_key = "ProductId"

    belongs_to :price_list, foreign_key: 'PriceLevelId', crm_key: 'pricelevelid'
    belongs_to :currency, foreign_key: 'TransactionCurrencyId', crm_key: 'transactioncurrencyid'

    has_many :notes, foreign_key: 'ObjectId'
    has_many :invoice_products, foreign_key: 'ProductId'
    has_many :price_list_items, foreign_key: 'ProductId'

  end
end
