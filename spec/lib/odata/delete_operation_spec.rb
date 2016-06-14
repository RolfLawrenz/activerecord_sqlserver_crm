require 'rails_helper'

describe OData::DeleteOperation do
  let(:contact) {Crm::Contact.last}
  let(:invoice) {Crm::Invoice.new()}

  describe '#operation_body' do
    it 'should be empty' do
      operation = OData::DeleteOperation.new(invoice)
      expect(operation.operation_body).to eq("{}")
    end
  end

  describe '#handle_operation_response' do
    it 'should return error when http code 400' do
      response = Typhoeus::Response.new(code: 400, body: "{\"error\":{\"message\":\"test error\"}}", headers: {'Content-Type'=> "application/json"})
      operation = OData::DeleteOperation.new(invoice)
      operation.handle_operation_response(response)
      expect(invoice.errors.size).to eq(1)
      expect(invoice.errors.messages[:base][0]).to eq("test error [http code 400]")
      expect(invoice.id).to be_nil
    end

    it 'should return successful' do
      response = Typhoeus::Response.new(code: 200, body: "{}", headers: {'OData-EntityId'=> "(55555555-6666-7777-8888-000000000000)"})
      operation = OData::DeleteOperation.new(invoice)
      operation.handle_operation_response(response)
      expect(invoice.errors.size).to eq(0)
    end
  end

  describe '#operation_url' do
    it 'should return contact url' do
      operation = OData::DeleteOperation.new(invoice)
      invoice.id = "123"
      expect(operation.operation_url).to end_with("invoices()")
    end
  end

end