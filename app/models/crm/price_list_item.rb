module Crm
  class PriceListItem < ActiveRecord::Base
    self.table_name = "ProductPriceLevel"
    self.primary_key = "ProductPriceLevelId"

    belongs_to :price_list, foreign_key: 'PriceLevelId', crm_key: 'pricelevelid'
    belongs_to :product, foreign_key: 'ProductId', crm_key: 'productid'

  end
end
