require 'rails_helper'

describe "merchant bulk discounts edit" do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 3)

    visit edit_merchant_bulk_discount_path(@merchant1, @bulk_discount1)
  end

  it "has a form to edit the bulk discount that is prefilled with the existing data" do
   expect(page).to have_field("Percentage Discount", with: @bulk_discount1.percentage_discount)
   expect(page).to have_field("Quantity Threshold", with: @bulk_discount1.quantity_threshold)
  end

  it "redirects to the index where the changes can be seen after valid data is submitted" do
    visit merchant_bulk_discounts_path(@merchant1)

    within "#discount_#{@bulk_discount1.id}" do
      expect(page).to have_content("20%")
      expect(page).to have_content("Quantity Threshold: 3")
    end

    visit edit_merchant_bulk_discount_path(@merchant1)
    fill_in "Percentage Discount", with: 50
    click_button "Submit"

    within "#discount_#{@bulk_discount1.id}" do
      expect(page).to have_content("50%")
      expect(page).to have_content("Quantity Threshold: 3")
    end
  end
end
