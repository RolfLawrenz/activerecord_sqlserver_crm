module Crm
  class Account < ActiveRecord::Base
    self.table_name = "Account"
    self.primary_key = "AccountId"

    has_many :notes, foreign_key: 'ObjectId', class_name: "Crm::AccountNote"
    has_many :cases, foreign_key: 'AccountId'
    has_many :opportunities, foreign_key: 'AccountId'

    validates :Name, presence: true

  end
end
