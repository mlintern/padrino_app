migration 1, :create_accounts do
  up do
    create_table :accounts do
      column :id, DataMapper::Property::UUID
      column :username, DataMapper::Property::String, :length => 255
      column :name, DataMapper::Property::String, :length => 255
      column :surname, DataMapper::Property::String, :length => 255
      column :email, DataMapper::Property::String, :length => 255
      column :crypted_password, DataMapper::Property::String, :length => 255
      column :token, DataMapper::Property::String, :length => 255
      column :role, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :accounts
  end
end
