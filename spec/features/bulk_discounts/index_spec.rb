require 'rails_helper'

describe "merchant bulk discounts index" do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @merchant2 = Merchant.create!(name: 'Jewelry')

    @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 3)
    @bulk_discount2 = @merchant1.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 5)
    @bulk_discount3 = @merchant2.bulk_discounts.create!(percentage_discount: 35, quantity_threshold: 10)

    visit merchant_bulk_discounts_path(@merchant1)
  end

  it "has all of a merchant's bulk discounts including their percentage discount and quantity threshold" do
    within "#discount_#{@bulk_discount1.id}" do
      expect(page).to have_content(@bulk_discount1.id)
      expect(page).to have_content(@bulk_discount1.percentage_discount)
      expect(page).to have_content(@bulk_discount1.quantity_threshold)
    end

    within "#discount_#{@bulk_discount2.id}" do
      expect(page).to have_content(@bulk_discount2.id)
      expect(page).to have_content(@bulk_discount2.percentage_discount)
      expect(page).to have_content(@bulk_discount2.quantity_threshold)
    end

    expect(page).not_to have_content(@bulk_discount3.id)
  end

  it "has a link to each bulk discount's show page" do
    click_link "Bulk Discount #{@bulk_discount1.id}"

    expect(page).to have_current_path(merchant_bulk_discount_path(@merchant1, @bulk_discount1))

    visit merchant_bulk_discounts_path(@merchant1)

    click_link "Bulk Discount #{@bulk_discount2.id}"

    expect(page).to have_current_path(merchant_bulk_discount_path(@merchant1, @bulk_discount2))
  end

  it "has a link to create a new discount" do
    click_link "Create Discount"

    expect(page).to have_current_path(new_merchant_bulk_discount_path(@merchant1))
  end

  it "has a link next to each discount to delete that discount" do
    within "#discount_#{@bulk_discount1.id}" do
      expect(page).to have_content(@bulk_discount1.id)
      expect(page).to have_content(@bulk_discount1.percentage_discount)
      expect(page).to have_content(@bulk_discount1.quantity_threshold)
      click_link "Delete"
    end
    expect(page).to have_current_path(merchant_bulk_discounts_path(@merchant1))
    expect(page).not_to have_content("Bulk Discount #{@bulk_discount1.id}")
    expect(page).not_to have_content("Percentage Discount: #{@bulk_discount1.percentage_discount}%")
    expect(page).not_to have_content("Quantity Threshold: #{@bulk_discount1.quantity_threshold}")
  end
end
