class Document 

  include Mongoid::Document
  include Mongoid::Paperclip
      
  
  has_mongoid_attached_file :file,
        :path => ":rails_root/public/documents/:id/:filename",
	    :url => "/documents/:id/:filename"

  belongs_to :user
  has_and_belongs_to_many :tags
  
  include Sunspot::Mongoid
  searchable do
    text :title, :boost => 4
    text :description, :boost => 3
    text :data, :boost => 5

  end

  field :title, type: String
  field :description, type: String
  field :path_to_file, type: String
  field :data, type: String
  field :user_id, type: String
  field :date_created, type: String

  validates_presence_of :title, :tag_ids


end
