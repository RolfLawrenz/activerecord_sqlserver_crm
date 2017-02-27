module Crm
  class UomSchedule < ::ApplicationRecord
    self.table_name = "UoMSchedule"
    self.primary_key = "UoMScheduleId"

    has_many :uoms, foreign_key: 'UoMScheduleId'

    validates :Name, presence: true

  end
end
