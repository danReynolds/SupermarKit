class Grocery < ActiveRecord::Base
  validates :name, presence: true
	has_and_belongs_to_many :items
  belongs_to :user_group

  def total
    Money.new(items.sum(:price_cents)).format(symbol: false).to_f
  end

  def finished?
    finished_at.present?
  end
end
