module Crm
  class Contact < ActiveRecord::Base
    self.table_name = "Contact"
    self.primary_key = "ContactId"

    has_many :invoices, foreign_key: 'ContactId'

    validates :FirstName, presence: true
    validates :LastName, presence: true

  end
end
