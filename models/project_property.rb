class ProjectProperty
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id,               UUID, :key => true, :unique_index => false
  property :name,             String
  property :value,            String

  validates_presence_of       :id
  validates_presence_of       :name
end