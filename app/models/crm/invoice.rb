module Crm
  class Invoice < ActiveRecord::Base
    self.table_name = "Invoice"
    self.primary_key = "InvoiceId"

    belongs_to :contact, foreign_key: 'InvoiceId', crm_key: 'customerid_contact'

  end
end