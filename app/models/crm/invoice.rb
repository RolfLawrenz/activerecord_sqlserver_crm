module Crm
  class Invoice < ActiveRecord::Base
    self.table_name = "Invoice"
    self.primary_key = "InvoiceId"

    belongs_to :account, foreign_key: 'AccountId', crm_key: 'customerid_account'
    belongs_to :contact, foreign_key: 'ContactId', crm_key: 'customerid_contact'
    belongs_to :price_list, foreign_key: 'PriceLevelId', crm_key: 'pricelevelid'
    belongs_to :currency, foreign_key: 'TransactionCurrencyId', crm_key: 'transactioncurrencyid'

    has_many :invoice_products, foreign_key: 'InvoiceId'
    has_many :notes, foreign_key: 'ObjectId'

    validates :Name, presence: true
    validates :price_list, presence: true

    validate :contact_xor_account

    private

    def contact_xor_account
      unless contact.blank? ^ account.blank?
        errors.add(:base, "Specify a contact or account, not both")
      end
    end

  end
end