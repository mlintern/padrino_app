# frozen_string_literal: true

migration 14, :create_uploaded_files do
  up do
    create_table :uploaded_files do
      column :id, DataMapper::Property::UUID
      column :name, DataMapper::Property::String, length: 255
      column :path, DataMapper::Property::String, allow_nil: false
      column :md5sum, DataMapper::Property::String, allow_nil: false
      column :size, DataMapper::Property::String
      column :last_update, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :files
  end
end
