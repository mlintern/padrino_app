migration 4, :create_account_properties do
  up do
    create_table :account_properties do
      column :id, DataMapper::Property::Integer
      column :name, DataMapper::Property::String, :length => 255
      column :value, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :account_property
  end
end