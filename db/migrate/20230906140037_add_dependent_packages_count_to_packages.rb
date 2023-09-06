class AddDependentPackagesCountToPackages < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :dependent_packages_count, :integer, default: 0
    add_column :packages, :last_package_dependency_id, :integer
  end
end
