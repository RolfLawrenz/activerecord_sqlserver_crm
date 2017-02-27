module Crm
  class Contact < ::ApplicationRecord
    self.table_name = "Contact"
    self.primary_key = "ContactId"

    has_many :cases, foreign_key: 'ContactId'
    has_many :invoices, foreign_key: 'ContactId'
    has_many :notes, foreign_key: 'ObjectId', class_name: "Crm::ContactNote"
    has_many :opportunities, foreign_key: 'ContactId'

    validates :FirstName, presence: true
    validates :LastName, presence: true

  end
end
