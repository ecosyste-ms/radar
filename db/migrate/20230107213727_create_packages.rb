class CreatePackages < ActiveRecord::Migration[7.0]
  def change
    create_table :packages do |t|
      t.integer :registry_id
      t.string :name
      t.string :ecosystem
      t.text :description
      t.text :keywords
      t.string :homepage
      t.string :licenses
      t.string :repository_url
      t.string :normalized_licenses
      t.integer :versions_count
      t.datetime :latest_release_published_at
      t.string :latest_release_number
      t.string :keywords_array
      t.string :language
      t.string :status
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
