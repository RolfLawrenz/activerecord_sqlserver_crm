module Crm
  class Product < ActiveRecord::Base
    self.table_name = "Product"
    self.primary_key = "ProductId"

    belongs_to :price_list, foreign_key: 'InvoiceId', crm_key: 'pricelevelid'

    has_many :notes, foreign_key: 'ObjectId'
    has_many :cases, foreign_key: 'ProductId'

  end
end
