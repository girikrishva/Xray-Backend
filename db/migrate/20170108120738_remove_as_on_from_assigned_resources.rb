class RemoveAsOnFromAssignedResources < ActiveRecord::Migration
  def change
    remove_column :assigned_resources, :as_on
  end
end
