module Crm
  class Contact < ActiveRecord::Base
    self.table_name = "Contact"
    self.primary_key = "ContactId"

    has_many :cases, foreign_key: 'ContactId'
    has_many :invoices, foreign_key: 'ContactId'
    has_many :notes, foreign_key: 'ObjectId', class_name: "Crm::ContactNote"

    validates :FirstName, presence: true
    validates :LastName, presence: true

  end
end
