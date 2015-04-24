migration 6, :add_last_login do
  up do
    modify_table :accounts do
      add_column :last_login, DataMapper::Property::DateTime, :allow_nil => true
    end
  end

  down do
    drop_column :last_update
  end
end