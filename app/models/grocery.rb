class Grocery < ActiveRecord::Base
  has_many :groceries_items, class_name: GroceriesItems
  has_many :items, through: :groceries_items
  belongs_to :user_group
  belongs_to :grocery_store

  validates :name, presence: true

  def total_price_or_estimated
    total = items.inject(0) do |acc, i|
      acc += i.total_price_or_estimated(self)
    end
    Money.new(total).format(symbol: false).to_f
  end

  def finished?
    finished_at.present?
  end
end
