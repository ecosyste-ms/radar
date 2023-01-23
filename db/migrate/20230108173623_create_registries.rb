class CreateRegistries < ActiveRecord::Migration[7.0]
  def change
    create_table :registries do |t|
      t.string :name
      t.string :url
      t.string :ecosystem
      t.boolean :default
      t.integer :packages_count
      t.string :github
      t.json :metadata

      t.timestamps
    end
  end
end
