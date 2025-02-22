class Merchant < ApplicationRecord
  validates_presence_of :name
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :bulk_discounts

  enum status: [:enabled, :disabled]

  def favorite_customers
    transactions.joins(invoice: :customer)
                .where('result = ?', 1)
                .where("invoices.status = ?", 2)
                .select("customers.*, count('transactions.result') as top_result")
                .group('customers.id')
                .order(top_result: :desc)
                .distinct
                .limit(5)
  end

  def ordered_items_to_ship
    item_ids = InvoiceItem.where("status = 0 OR status = 1").order(:created_at).pluck(:item_id)
    item_ids.map do |id|
      Item.find(id)
    end
  end

  def top_5_items
     items
     .joins(invoices: :transactions)
     .where('transactions.result = 1')
     .select("items.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
     .group(:id)
     .order('total_revenue desc')
     .limit(5)
   end

  def self.top_merchants
    joins(invoices: [:invoice_items, :transactions])
    .where('result = ?', 1)
    .select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
    .group(:id)
    .order('total_revenue DESC')
    .limit(5)
  end

  def best_day
    invoices.where("invoices.status = 2")
            .joins(:invoice_items)
            .select('invoices.created_at, sum(invoice_items.unit_price * invoice_items.quantity) as revenue')
            .group("invoices.created_at")
            .order("revenue desc", "invoices.created_at desc")
            .first&.created_at&.to_date
  end

  def create_invoice_item_discounts
    invoice_items.each do |invoice_item|
      self.bulk_discounts.each do |bulk_discount|
        if invoice_item.quantity >= bulk_discount.quantity_threshold
          if InvoiceItemDiscount.exists?(invoice_item_id: invoice_item.id)
            if BulkDiscount.find(InvoiceItemDiscount.find_by(invoice_item_id: invoice_item.id).bulk_discount_id).percentage_discount < bulk_discount.percentage_discount
              InvoiceItemDiscount.find_by(invoice_item_id: invoice_item.id).update(bulk_discount_id: bulk_discount.id)
            end
          else
            InvoiceItemDiscount.create(invoice_item_id: invoice_item.id, bulk_discount_id: bulk_discount.id)
          end
        end
      end
    end
  end

  def merchant_revenue(invoice)
    invoice_items.where(invoice_id: invoice.id)
    .sum('quantity * invoice_items.unit_price')
  end

  def discounted_merchant_revenue(invoice)
    create_invoice_item_discounts
    self.discounted_items_price(invoice) + self.full_items_price(invoice)
  end
  
  def discounted_items_price(invoice)
    invoice_items.joins(:bulk_discounts)
    .where(invoice_id: invoice.id)
    .sum('(invoice_items.quantity * invoice_items.unit_price) * ((100 - bulk_discounts.percentage_discount) / 100.0)')
  end

  def full_items_price(invoice)
    invoice_items.left_joins(:bulk_discounts)
    .where(invoice_id: invoice.id, bulk_discounts: {id: nil})
    .sum('(invoice_items.quantity * invoice_items.unit_price)')
  end
end
#self.invoice_items.joins(:bulk_discounts).select("invoice_items.*, max(SELECT bulk_discounts.percentage_discount WHERE invoice_items.quantity >= bulk_discounts.quantity_threshold) as applied_discount").