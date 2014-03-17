json.array!(@documents) do |document|
  json.extract! document, :title, :description, :data
  json.url document_url(document, format: :json)
end
