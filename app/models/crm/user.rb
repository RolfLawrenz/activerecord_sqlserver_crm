module Crm
  class User < ActiveRecord::Base
    self.table_name = "SystemUser"
    self.primary_key = "SystemUserId"

    has_many :notes, foreign_key: 'ObjectId'

    validates :FirstName, presence: true
    validates :LastName, presence: true

  end
end
