class ProjectStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :projects, class_name: 'Project'

  def self.id_for_status(status_name)
    ProjectStatus.where('name = ?', status_name).first.id
  end
end