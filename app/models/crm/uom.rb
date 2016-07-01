module Crm
  class Uom < ActiveRecord::Base
    self.table_name = "UoM"
    self.primary_key = "UoMId"

    has_many :invoice_products, foreign_key: 'UoMId'

  end
end
