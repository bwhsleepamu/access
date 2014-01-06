json.array!(@subjects) do |subject|
  json.extract! subject, :id, :subject_code
  json.path subject_path(subject, format: :json)
end
