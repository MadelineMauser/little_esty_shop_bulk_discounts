class InvoiceItemDiscount < ApplicationRecord
  validates_presence_of :invoice_item_id,
                        :bulk_discount_id

  belongs_to :invoice_item
  belongs_to :bulk_discount
end
