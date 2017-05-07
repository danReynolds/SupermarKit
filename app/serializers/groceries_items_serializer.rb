class GroceriesItemsSerializer < ActiveModel::Serializer
  attributes :id, :units, :display_name, :requester_ids
  attribute :price do
    object.price.format(symbol: false).to_f
  end
  attribute :estimated_price do
    object.estimated_price.format(symbol: false).to_f
  end
  attribute :quantity do
    object.quantity.to_f
  end
end
