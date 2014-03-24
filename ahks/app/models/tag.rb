class Tag
  include Mongoid::Document

  belongs_to :user
  has_and_belongs_to_many :transcriptions
  has_and_belongs_to_many :documents

  field :name, type: String
  field :description, type: String
  field :user_id, type: String
  field :date_created, type: String

  validates_presence_of :name, :description
end
