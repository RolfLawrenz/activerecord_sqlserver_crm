module Crm
  class Invoice < ActiveRecord::Base
    self.table_name = "Invoice"
    self.primary_key = "InvoiceId"

    belongs_to :contact, foreign_key: 'InvoiceId', crm_key: 'customerid_contact'
    belongs_to :price_list, foreign_key: 'InvoiceId', crm_key: 'pricelevelid'

    has_many :invoice_products, foreign_key: 'InvoiceId'
    has_many :notes, foreign_key: 'ObjectId'

  end
end