require 'rails_helper'

# To find out required fields. In database:
#
# SELECT
# e.PhysicalName AS EntityPhysicalName,
#                   a.PhysicalName AS AttributePhysicalName,
#                                     a.AttributeRequiredLevelId
# FROM TEST_MSCRM..AttributeView AS a
# JOIN TEST_MSCRM..EntityView AS e ON a.EntityId = e.EntityId
# WHERE e.Name ='campaign'
# AND a.AttributeRequiredLevelId <> 'none'

REQUIRED_FIELD_VALUES = {
    Crm::Account => {"Name" => "Company"},
    Crm::AccountNote => {"Subject" => "Note1"},
    Crm::Campaign => {"currency" => Crm::Currency.last, "Name" => "Campaign"},
    Crm::CampaignNote => {"Subject" => "Note1"},
    Crm::CampaignResponse => {"Subject" => "John", "campaign" => Crm::Campaign.last},
    Crm::CampaignResponseNote => {"Subject" => "Note1"},
    Crm::Case => {"Title" => "Case1", "contact" => Crm::Contact.last},
    Crm::CaseNote => {"Subject" => "Note1"},
    Crm::Contact => {"FirstName" => "John", "LastName" => "Smith"},
    Crm::ContactNote => {"Subject" => "Note1"},
    Crm::Currency => {"CurrencyName" => "Elvish", "CurrencyPrecision" => 2, "CurrencySymbol" => "Z", "ExchangeRate" => BigDecimal.new("1.23"), "ISOCurrencyCode" => "GBP"},
    Crm::Invoice => {"contact" => Crm::Contact.last, "Name" => "Inv1", "InvoiceNumber" => "InvNum1", "price_list" => Crm::PriceList.last},
    Crm::InvoiceNote => {"Subject" => "Note1"},
    Crm::InvoiceProduct => {"invoice" => Crm::Invoice.last, "product" => Crm::Product.last, "Quantity" => BigDecimal.new("1.23"), "uom" => Crm::Uom.last},
    Crm::Opportunity => {"campaign" => Crm::Campaign.last},
    Crm::OpportunityNote => {"Subject" => "Note1"},
    Crm::PriceList => {"Name" => "PriceList1", "currency" => Crm::Currency.last},
    Crm::PriceListItem => {"price_list" => Crm::PriceList.last, "product" => Crm::Product.last, "Amount" => BigDecimal.new("3.45"), "uom" => Crm::Uom.last},
    Crm::Product => {"Name" => "Product#{Random.rand(10000)}", "QuantityDecimal" => BigDecimal.new("5.31"), "ProductNumber" => "prod#{Random.rand(10000)}", "default_uom" => Crm::Uom.last, "default_uom_schedule" => Crm::UomSchedule.last},
    Crm::Uom => {"Name" => "Uom1", "Quantity" => BigDecimal.new("0.83"), "uom_schedule" => Crm::UomSchedule.last},
    Crm::UomSchedule => {"Name" => "UomSched1"},
    Crm::User => {"FirstName" => "John", "LastName" => "Smith"},
}

UPDATE_FIELD_VALUES = {
    Crm::Account => {"Name" => "Test"},
    Crm::AccountNote => {"Subject" => "Test"},
    Crm::Campaign => {"Name" => "Test"},
    Crm::CampaignNote => {"Subject" => "Test"},
    Crm::CampaignResponse => {"Subject" => "Peter"},
    Crm::CampaignResponseNote => {"Subject" => "Test"},
    Crm::Case => {"Title" => "Test"},
    Crm::CaseNote => {"Subject" => "Test"},
    Crm::Contact => {"FirstName" => "Joe"},
    Crm::ContactNote => {"Subject" => "Test"},
    Crm::Currency => {"CurrencyName" => "Test"},
    Crm::Invoice => {"Name" => "Test"},
    Crm::InvoiceNote => {"Subject" => "Test"},
    Crm::InvoiceProduct => {"Quantity" => BigDecimal.new("2.34")},
    Crm::Opportunity => {"Name" => "Test"},
    Crm::OpportunityNote => {"Subject" => "Test"},
    Crm::PriceList => {"Name" => "Test"},
    Crm::PriceListItem => {"Amount" => BigDecimal.new("6.29")},
    Crm::Product => {"Name" => "Test"},
    Crm::Uom => {"Quantity" => BigDecimal.new("2.24")},
    Crm::UomSchedule => {"Name" => "Test"},
    Crm::User => {"FirstName" => "Test"},
}

MODELS_TO_SKIP_WRITE_TESTS = [
    Crm::Case,
    Crm::Note,
    Crm::Currency,
    Crm::UomSchedule,
    Crm::User
]

def model_classes
  @model_classes ||=
      begin
        models = []
        Dir["./app/models/**/*.rb"].sort.each do |file|
          next if File.basename(file, ".*") == "application_record"
          models << "Crm::#{File.basename(file, ".*").gsub('_ext','').camelize}".constantize
        end
        models
      end
end

def required_fields(model)
  fields = []
  model._validators.each do |field, validators|
    fields << field if validators.any?{|v| v.is_a?(ActiveRecord::Validations::PresenceValidator)}
  end
  fields
end

def required_field_and_values(model)
  required_fields(model).each_with_object({}) {|field, hsh| hsh[field] = "Test"}
end


describe Crm do

  context 'Read' do
    it 'should give a count' do
      puts "Count for:"
      model_classes.each do |model|
        puts "  #{model}"
        expect(model.count > 0)
      end
    end

    it 'should read last record' do
      puts "Last Record for:"
      model_classes.each do |model|
        puts "  #{model}"
        expect(model.last).not_to be_nil
      end
    end
  end

  context 'Associations' do
    it 'should test has_manys' do
      puts "Associations for has_many:"
      model_classes.each do |model|
        puts "  #{model}"
        assoc = model.reflect_on_all_associations
        has_manys = assoc.select { |a| a.macro == :has_many }
        last = model.last
        has_manys.each do |hm|
          puts "    #{hm.name}"
          expect{last.send(hm.name)}.not_to raise_error
        end
      end
    end

    it 'should test belongs_to' do
      puts "Associations for belongs_to:"
      model_classes.each do |model|
        puts "  #{model}"
        assoc = model.reflect_on_all_associations
        has_manys = assoc.select { |a| a.macro == :belongs_to }
        last = model.last
        has_manys.each do |hm|
          puts "    #{hm.name}"
          expect{last.send(hm.name)}.not_to raise_error
        end
      end
    end
  end

  context 'Write,Update,Delete' do
    it 'should create, update then delete a record' do
      puts "Write, Update, Delete for:"
      model_classes.each do |model|
        puts "  #{model}#{MODELS_TO_SKIP_WRITE_TESTS.include?(model) ? ' - SKIPPED' : ''}"
        # next unless model.to_s == "Crm::Opportunity"
        next if MODELS_TO_SKIP_WRITE_TESTS.include?(model)

        count = model.count
        record = model.create!(REQUIRED_FIELD_VALUES[model])
        expect(model.count).to eq(count + 1)

        record = record.reload
        raise "No update field set. Set in model_spec.rb" if UPDATE_FIELD_VALUES[model].nil?
        record.update!(UPDATE_FIELD_VALUES[model])
        expect(model.where(model.primary_key => record.id).first.send(UPDATE_FIELD_VALUES[model].keys[0].to_sym)).to eq(UPDATE_FIELD_VALUES[model].values[0])

        record.destroy!
        expect(model.count).to eq(count)
      end
    end
  end

end
