class RemoveClosureTreeFromContainer < ActiveRecord::Migration
  # THIS IS A BREAKING migration, we are not trying to migrate date
  # forward
  def change
    drop_table :container_hierarchies
    remove_column :containers,  :parent_id
  end
end
