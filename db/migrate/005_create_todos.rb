migration 5, :create_todos do
  up do
    create_table :todos do
      column :id, DataMapper::Property::UUID
      column :title, DataMapper::Property::String, :length => 255
      column :user_id, DataMapper::Property::String, :length => 255
      column :completed, DataMapper::Property::Boolean
    end
  end

  down do
    drop_table :todos
  end
end