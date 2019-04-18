# frozen_string_literal: true

migration 15, :add_uploaded_file_owner do
  up do
    modify_table :uploaded_files do
      add_column :account_id, DataMapper::Property::UUID
    end
  end

  down do
    drop_column :account_id
  end
end
