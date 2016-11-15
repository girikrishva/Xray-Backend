class AddIsLatestToResources < ActiveRecord::Migration
  def change
    add_column :resources, :is_latest, :boolean
  end
end
