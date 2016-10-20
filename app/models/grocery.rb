class Grocery < ActiveRecord::Base
  has_many :groceries_items, class_name: GroceriesItems
  has_many :payments, class_name: GroceryPayment
  has_many :items, through: :groceries_items
  has_and_belongs_to_many :recipes
  has_attached_file :receipt, styles: { clean: { processors: [:text_cleaner] } }
  belongs_to :user_group
  belongs_to :grocery_store

  validates_attachment :receipt, content_type: { content_type: /\Aimage\/.*\Z/ }
  validates :name, presence: true

  def total_price_or_estimated
    Money.new(
      groceries_items.includes(:item).inject(0) do |acc, grocery_item|
        acc += grocery_item.price_or_estimated
      end
    )
  end

  def payments_total
    Money.new(payments.sum(:price_cents))
  end

  def items_without_recipes
    items.includes(:recipes).where(recipes: { id: nil })
  end

  def finished?
    finished_at.present?
  end
end
