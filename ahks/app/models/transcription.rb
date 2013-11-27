class Transcription
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :path_to_audio, type: String
  field :text, type: String
  field :user_id, type: String
  field :date_created, type: String
end
