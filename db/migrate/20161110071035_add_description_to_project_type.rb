class AddDescriptionToProjectType < ActiveRecord::Migration
  def change
    add_column :project_types, :description, :string
  end
end
