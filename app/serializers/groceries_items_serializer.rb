class GroceriesItemsSerializer < ActiveModel::Serializer
  attributes :id, :units, :display_name, :requester_id
  attribute :price do
    object.price_or_estimated.format(symbol: false).to_f
  end
  attribute :quantity do
    object.quantity.to_f
  end
end
