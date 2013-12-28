class Transcription
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :audio,
        :path => ":rails_root/public/audio/:attachment/:id/:style/:filename",
	    :url => "/audio/:attachment/:id/:style/:filename"

  belongs_to :user
  has_and_belongs_to_many :tags
  field :name, type: String
  field :description, type: String
  field :path_to_audio, type: String
  field :text, type: String
  field :user_id, type: String
  field :date_created, type: String
end
