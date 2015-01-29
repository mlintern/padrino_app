migration 2, :add_last_update do
  up do
    modify_table :accounts do
      add_column :last_update, DataMapper::Property::DateTime, :length => 255
    end
  end
end