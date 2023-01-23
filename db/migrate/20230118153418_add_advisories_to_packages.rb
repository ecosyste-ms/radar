class AddAdvisoriesToPackages < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :advisories, :json, default: []
  end
end
