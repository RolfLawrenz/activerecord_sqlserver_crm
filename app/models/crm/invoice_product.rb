module Crm
  class InvoiceProduct < ActiveRecord::Base
    self.table_name = "InvoiceDetail"
    self.primary_key = "InvoiceDetailId"

    belongs_to :invoice, foreign_key: 'InvoiceDetailId', crm_key: 'invoiceid'

  end
end