json.array!(@transcriptions) do |transcription|
  json.extract! transcription, :name, :description, :path_to_audio, :text, :user_id, :date_created
  json.url transcription_url(transcription, format: :json)
end
