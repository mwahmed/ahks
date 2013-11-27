json.array!(@tags) do |tag|
  json.extract! tag, :name, :description, :user_id, :date_created
  json.url tag_url(tag, format: :json)
end
