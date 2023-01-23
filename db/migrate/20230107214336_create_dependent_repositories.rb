class CreateDependentRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :dependent_repositories do |t|
      t.integer :package_id
      t.string :full_name
      t.string :resolved_versions, array: true, default: []
      t.string :resolved_major_versions, array: true, default: []
      t.string :resolved_minor_versions, array: true, default: []
      t.string :resolved_patch_versions, array: true, default: []
      t.boolean :direct_dependency
      t.json :repository_fields
      t.json :manifests

      t.timestamps
    end
  end
end
