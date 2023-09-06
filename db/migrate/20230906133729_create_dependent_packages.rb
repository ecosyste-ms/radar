class CreateDependentPackages < ActiveRecord::Migration[7.0]
  def change
    create_table :dependent_packages do |t|
      t.integer :package_id
      t.string :name
      t.string :resolved_versions, array: true, default: []
      t.string :resolved_major_versions, array: true, default: []
      t.string :resolved_minor_versions, array: true, default: []
      t.string :resolved_patch_versions, array: true, default: []
      t.json :package_fields
      t.json :versions

      t.timestamps
    end
  end
end

