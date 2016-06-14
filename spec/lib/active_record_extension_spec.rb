require 'rails_helper'

describe ActiveRecordExtension do

  before(:all) do
    @test_contact = Crm::Contact.new(FirstName: 'Test', LastName: "Testerson")
    @test_contact.save
    @test_contact2 = Crm::Contact.new(FirstName: 'Test', LastName: "Testerson")
    @test_contact2.save
  end

  after(:all) do
    @test_contact.destroy
  end

  describe '#save' do
    it 'create a new contact' do
      count = Crm::Contact.count
      contact = Crm::Contact.new(FirstName: 'Test', LastName: "Testerson")
      retval = contact.save
      expect(Crm::Contact.count).to eq(count + 1)
      expect(contact.id).not_to be_nil
      expect(contact.errors.messages).to be_empty
      expect(retval).to be(true)
      contact.destroy
    end

    it 'fails to create a contact when names not given' do
      count = Crm::Contact.count
      contact = Crm::Contact.new()
      retval = contact.save
      expect(Crm::Contact.count).to eq(count)
      expect(contact.errors.messages).to eq({:FirstName=>["can't be blank"], :LastName=>["can't be blank"]})
      expect(retval).to be(false)
    end

    it 'updates a contact' do
      count = Crm::Contact.count
      contact = @test_contact
      ext = "Test#{Random.rand(10000)}"
      contact.AssistantName = ext
      contact.save
      contact.reload
      expect(Crm::Contact.count).to eq(count)
      expect(contact.AssistantName).to eq(ext)
    end

    it 'fails to update a contact when names not given' do
      contact = @test_contact2
      contact.FirstName = nil
      contact.save
      expect(contact.errors.messages).to eq({:FirstName=>["can't be blank"]})
      contact.reload
      expect(contact.FirstName).not_to be_nil
    end
  end

  describe '#save!' do
    it 'fails to create a contact when names not given' do
      count = Crm::Contact.count
      contact = Crm::Contact.new()
      expect { contact.save! }.to raise_error(ActiveRecord::RecordInvalid,"Validation failed: Firstname can't be blank, Lastname can't be blank")
      expect(Crm::Contact.count).to eq(count)
    end
  end

  describe '#update' do
    it 'updates a contact' do
      contact = @test_contact
      ext = "Test#{Random.rand(10000)}"
      contact.update(AssistantName: ext)
      expect(contact.errors.messages).to be_empty
      expect(contact.AssistantName).to eq(ext)
    end

    it 'fails to update a contact' do
      contact = @test_contact2
      contact.update(FirstName: nil)
      expect(contact.errors.messages).to eq({:FirstName=>["can't be blank"]})
      contact.reload
      expect(contact.FirstName).not_to be_nil
    end
  end

  describe '#update_attribute' do
    it 'updates a contact' do
      contact = @test_contact
      ext = "Test#{Random.rand(10000)}"
      contact.update_attribute('AssistantName', ext)
      expect(contact.errors.messages).to be_empty
      expect(contact.AssistantName).to eq(ext)
    end

    it 'fails to update a contact' do
      contact = @test_contact2
      contact.update_attribute('FirstName', nil)
      expect(contact.errors.messages).to eq({:FirstName=>["can't be blank"]})
      contact.reload
      expect(contact.FirstName).not_to be_nil
    end
  end

  describe '#destroy' do
    it 'destroys a contact' do
      contact = Crm::Contact.new(FirstName: 'Test', LastName: "Testerson")
      contact.save
      count = Crm::Contact.count
      contact.destroy
      expect(contact.errors.messages).to be_empty
      expect(Crm::Contact.count).to eq(count - 1)
    end
  end

  describe '#destroy!' do
    it 'destroys a contact' do
      contact = Crm::Contact.new(FirstName: 'Test', LastName: "Testerson")
      contact.save
      count = Crm::Contact.count
      contact.destroy!
      expect(contact.errors.messages).to be_empty
      expect(Crm::Contact.count).to eq(count - 1)
    end
  end

end
