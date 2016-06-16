module Crm
  class User < ActiveRecord::Base
    self.table_name = "SystemUser"
    self.primary_key = "SystemUserId"

    has_many :activity_parties, foreign_key: 'PartyId'
    has_many :notes, foreign_key: 'ObjectId'

  end
end
