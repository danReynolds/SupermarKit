class RecipeSerializer < ActiveModel::Serializer
  attributes :external_id, :name, :rating, :timeInSeconds, :url
  attribute :image_url, key: :image
end
