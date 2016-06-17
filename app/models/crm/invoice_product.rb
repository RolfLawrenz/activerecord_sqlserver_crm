module Crm
  class InvoiceProduct < ActiveRecord::Base
    self.table_name = "InvoiceDetail"
    self.primary_key = "InvoiceDetailId"

    belongs_to :invoice, foreign_key: 'InvoiceDetailId', crm_key: 'invoiceid'
    belongs_to :product, foreign_key: 'InvoiceDetailId', crm_key: 'productid'
    belongs_to :currency, foreign_key: 'InvoiceDetailId', crm_key: 'transactioncurrencyid'
    belongs_to :original_currency, foreign_key: 'InvoiceDetailId', crm_key: 'new_originalcurrency', class_name: 'Crm::Currency'

  end
end