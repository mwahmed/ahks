class Tag
  include Mongoid::Document
  belongs_to :user
  has_and_belongs_to_many :transcriptions
  field :name, type: String
  field :description, type: String
  field :user_id, type: String
  field :date_created, type: String
end
