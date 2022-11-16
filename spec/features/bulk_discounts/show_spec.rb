require 'rails_helper'

describe "merchant bulk discounts show" do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
   
    @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 3)
  
    visit merchant_bulk_discount_path(@merchant1, @bulk_discount1)
  end

  it "has the bulk discount's percentage discount and quantity threshold" do
      expect(page).to have_content(@bulk_discount1.id)
      expect(page).to have_content(@bulk_discount1.percentage_discount)
      expect(page).to have_content(@bulk_discount1.quantity_threshold)
  end
end
