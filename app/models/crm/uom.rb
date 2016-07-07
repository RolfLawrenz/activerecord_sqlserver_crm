module Crm
  class Uom < ActiveRecord::Base
    self.table_name = "UoM"
    self.primary_key = "UoMId"

    belongs_to :uom_schedule, foreign_key: 'UoMScheduleId', crm_key: 'uomscheduleid'

    has_many :invoice_products, foreign_key: 'UoMId'

    validates :Name, presence: true
    validates :Quantity, presence: true
    validates :uom_schedule, presence: true

  end
end
