module Crm
  class PriceListItem < ActiveRecord::Base
    self.table_name = "ProductPriceLevel"
    self.primary_key = "ProductPriceLevelId"

    belongs_to :price_list, foreign_key: 'ProductPriceLevelId', crm_key: 'pricelevelid'

  end
end
