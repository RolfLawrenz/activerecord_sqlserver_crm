module Crm
  class Product < ActiveRecord::Base
    self.table_name = "Product"
    self.primary_key = "ProductId"

    belongs_to :price_list, foreign_key: 'PriceLevelId', crm_key: 'pricelevelid'
    belongs_to :currency, foreign_key: 'TransactionCurrencyId', crm_key: 'transactioncurrencyid'
    belongs_to :default_uom, foreign_key: 'DefaultUoMId', crm_key: 'defaultuomid', class_name: 'Crm::Uom'
    belongs_to :default_uom_schedule, foreign_key: 'DefaultUoMScheduleId', crm_key: 'defaultuomscheduleid', class_name: 'Crm::UomSchedule'

    has_many :notes, foreign_key: 'ObjectId'
    has_many :invoice_products, foreign_key: 'ProductId'
    has_many :price_list_items, foreign_key: 'ProductId'

    validates :Name, presence: true
    validates :QuantityDecimal, presence: true
    validates :ProductNumber, presence: true
    validates :default_uom, presence: true
    validates :default_uom_schedule, presence: true

  end
end
