require 'rails_helper'

describe OData::CreateOperation do
  let(:contact) {Crm::Contact.last}
  let(:invoice) {Crm::Invoice.new()}

  describe '#operation_body' do
    it 'should empty body when no changes in record' do
      operation = OData::CreateOperation.new(invoice)
      expect(operation.operation_body).to eq("{}")
    end

    it 'should include first name in body when added in record' do
      invoice.Name = "Bill"
      operation = OData::CreateOperation.new(invoice)
      expect(operation.operation_body).to eq("{\"name\":\"Bill\"}")
    end

    it 'should include association in body when added in record' do
      invoice2 = Crm::Invoice.new(contact: contact)
      operation = OData::CreateOperation.new(invoice2)
      expect(operation.operation_body).to start_with("{\"customerid_contact@odata.bind\":\"/contacts(")
    end
  end

  describe '#handle_operation_response' do
    it 'should return error when http code 400' do
      response = Typhoeus::Response.new(code: 400, body: "{\"error\":{\"message\":\"test error\"}}", headers: {'Content-Type'=> "application/json"})
      operation = OData::CreateOperation.new(invoice)
      operation.handle_operation_response(response)
      expect(invoice.errors.size).to eq(2)
      expect(invoice.errors.messages[:base][0]).to eq("Could not create entity. [http code 400]")
      expect(invoice.errors.messages[:base][1]).to eq("test error [http code 400]")
      expect(invoice.id).to be_nil
    end

    it 'should return error when empty ODataId' do
      response = Typhoeus::Response.new(code: 400, body: "{}", headers: {'OData-EntityId'=> ""})
      operation = OData::CreateOperation.new(invoice)
      operation.handle_operation_response(response)
      expect(invoice.errors.size).to eq(2)
      expect(invoice.errors.messages[:base][0]).to eq("Failed to create entity. [http code 400]")
      expect(invoice.errors.messages[:base][1]).to eq("An error occurred [http code 400]")
    end

    it 'should return successful with id' do
      response = Typhoeus::Response.new(code: 200, body: "{}", headers: {'OData-EntityId'=> "(55555555-6666-7777-8888-000000000000)"})
      operation = OData::CreateOperation.new(invoice)
      operation.handle_operation_response(response)
      expect(invoice.errors.size).to eq(0)
      expect(invoice.id).to eq("55555555-6666-7777-8888-000000000000")
    end
  end

  describe '#operation_url' do
    it 'should return contact url' do
      operation = OData::CreateOperation.new(invoice)
      expect(operation.operation_url).to end_with("invoices")
    end
  end

end