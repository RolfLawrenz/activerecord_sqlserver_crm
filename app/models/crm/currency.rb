module Crm
  class Currency < ::ApplicationRecord
    self.table_name = "TransactionCurrency"
    self.primary_key = "TransactionCurrencyId"

    validates :CurrencyName, presence: true
    validates :CurrencyPrecision, presence: true
    validates :CurrencySymbol, presence: true
    validates :ExchangeRate, presence: true
    validates :ISOCurrencyCode, presence: true

  end
end
