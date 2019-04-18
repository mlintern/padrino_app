# frozen_string_literal: true

# UploadedFile Class
class UploadedFile
  include DataMapper::Resource
  # storage_names[:default] = 'files'

  property :id,           String, length: 36, key: true, unique: true, auto_validation: false, default: ->(_r, _p) { Nretnil::Password.uuid }
  property :name,         String
  property :path,         FilePath, required: true
  property :md5sum,       String, length: 32, unique: true, default: ->(r, _p) { Digest::MD5.hexdigest(r.path) }
  property :size,         String, default: ->(r, _p) { File.size(r.path).to_human(1) }
  property :last_update,  DateTime

  belongs_to :account, key: true

  # Validators
  validates_presence_of :id
  validates_presence_of :path

  # Callbacks
  before :save, :set_time

  def set_time
    self.last_update = Time.new.utc
  end

  def url
    '/cdn/files/' + name
  end
end
