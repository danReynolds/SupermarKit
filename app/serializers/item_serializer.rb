class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  attribute :links, if: :with_link?
  has_one :grocery_item, if: :with_grocery_item? do
    object.groceries_items.find_by_grocery_id(scope)
  end

  def with_grocery_item?
    instance_options[:scope_name] == :grocery
  end

  def with_link?
    instance_options[:with_link].present?
  end

  def links
    { self: item_path(object) }
  end
end
