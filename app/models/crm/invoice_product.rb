module Crm
  class InvoiceProduct < ActiveRecord::Base
    self.table_name = "InvoiceDetail"
    self.primary_key = "InvoiceDetailId"

    belongs_to :invoice, foreign_key: 'InvoiceId', crm_key: 'invoiceid'
    belongs_to :product, foreign_key: 'ProductId', crm_key: 'productid'
    belongs_to :currency, foreign_key: 'TransactionCurrencyId', crm_key: 'transactioncurrencyid'
    belongs_to :original_currency, foreign_key: 'new_OriginalCurrency', crm_key: 'new_originalcurrency', class_name: 'Crm::Currency'
    belongs_to :uom, foreign_key: 'UoMId', crm_key: 'uomid'

    validates :invoice, presence: true
    validates :product, presence: true
    validates :uom, presence: true
    validates :Quantity, presence: true

  end
end