module Crm
  class InvoiceNote < Note
    belongs_to :invoice, foreign_key: 'ObjectId', crm_key: 'objectid_invoice'
  end
end
