class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :items, -> { uniq }, through: :groceries
  has_many :groceries

  validates :name, presence: true, uniqueness: true

  def active_groceries
    groceries.where(finished_at: nil)
  end

  def finished_groceries
    groceries.where.not(finished_at: nil)
  end
end
