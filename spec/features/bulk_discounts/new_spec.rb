require 'rails_helper'

describe "merchant bulk discounts new" do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')

    visit new_merchant_bulk_discount_path(@merchant1)
  end

  it "has a form to create a new bulk discount that redirects to the bulk discount index when valid data is submitted" do
   fill_in "Percentage Discount", with: 40
   fill_in "Quantity Threshold", with: 6
   click_button "Create Discount"

   expect(page).to have_current_path(merchant_bulk_discounts_path(@merchant1))
  end

  it "shows the newly created discount after valid data is submitted" do
    visit merchant_bulk_discounts_path(@merchant1)
    expect(page).not_to have_content(40)
    expect(page).not_to have_content(6)

    visit new_merchant_bulk_discount_path(@merchant1)
    fill_in "Percentage Discount", with: 40
    fill_in "Quantity Threshold", with: 6
    click_button "Create Discount"

    expect(page).to have_content(40)
    expect(page).to have_content(6)
  end
end
