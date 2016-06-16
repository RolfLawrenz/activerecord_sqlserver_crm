module Crm
  class Currency < ActiveRecord::Base
    self.table_name = "TransactionCurrency"
    self.primary_key = "TransactionCurrencyId"

  end
end
