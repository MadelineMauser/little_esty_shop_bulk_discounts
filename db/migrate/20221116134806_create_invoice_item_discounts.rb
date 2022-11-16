class CreateInvoiceItemDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_item_discounts do |t|
      t.references :invoice_item
      t.references :bulk_discount
    end
  end
end
