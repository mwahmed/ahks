class Tag
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :user_id, type: String
  field :date_created, type: String
end
