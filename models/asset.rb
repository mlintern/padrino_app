class Asset
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id,                UUID, :key => true, :unique_index => true
  property :project_id,        UUID
  property :external_id,       UUID
  property :title,             String
  property :body,              Text
  property :source,            Boolean, :default => false
  property :source_id,         UUID
  property :status,            Integer, :default => 0
  property :language,          String

  validates_presence_of        :id
  validates_presence_of        :project_id
  validates_presence_of        :title
  validates_presence_of        :body
  validates_presence_of        :language
end
