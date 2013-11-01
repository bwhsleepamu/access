json.array!(@studies) do |study|
  json.extract! study, 
  json.url study_url(study, format: :json)
end
