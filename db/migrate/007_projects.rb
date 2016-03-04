migration 3, :projects do
  up do
    create_table :projects do
      column :id, DataMapper::Property::UUID
      column :user_id, DataMapper::Property::UUID
      column :name, DataMapper::Property::String, :length => 255
      column :description, DataMapper::Property::Text
      column :status, DataMapper::Property::Integer
      column :language, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :projects
  end
end