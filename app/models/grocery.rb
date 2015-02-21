class Grocery < ActiveRecord::Base

  has_many :groceries_items, class_name: GroceriesItems
  has_many :items, through: :groceries_items
  belongs_to :user_group

  validates :name, presence: true

  def total
    Money.new(items.map{ |i| i.quantity(self) * i.price }.reduce(&:+)).format(symbol: false).to_f
  end

  def finished?
    finished_at.present?
  end
end
