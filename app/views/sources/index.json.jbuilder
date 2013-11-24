json.array!(@documentations) do |documentation|
  json.extract! documentation, :title, :author, :description
  json.url documentation_url(documentation, format: :json)
end
