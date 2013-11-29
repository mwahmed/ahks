class Transcription
  include Mongoid::Document
  belongs_to :user
  has_and_belongs_to_many :tags
  field :name, type: String
  field :description, type: String
  field :path_to_audio, type: String
  field :text, type: String
  field :user_id, type: String
  field :date_created, type: String
end
