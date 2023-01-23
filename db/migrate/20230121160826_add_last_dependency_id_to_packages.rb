class AddLastDependencyIdToPackages < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :last_dependency_id, :bigint
  end
end
