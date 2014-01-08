json.array!(@subjects) do |subject|
  json.extract! subject, :id, :subject_code
end
