module Crm
  class Account < ActiveRecord::Base
    self.table_name = "Account"
    self.primary_key = "AccountId"

    has_many :notes, foreign_key: 'ObjectId'
    has_many :cases, foreign_key: 'AccountId'

  end
end
