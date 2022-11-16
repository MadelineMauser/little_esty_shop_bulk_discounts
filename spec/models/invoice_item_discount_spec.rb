require 'rails_helper'

RSpec.describe InvoiceItemDiscount, type: :model do
  describe "validations" do
    it { should validate_presence_of :bulk_discount_id }
    it { should validate_presence_of :invoice_item_id }
  end
  describe "relationships" do
    it { should belong_to :invoice_item }
    it { should belong_to :bulk_discount }
  end
end