class ProjectStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :projects, class_name: 'Project'

# default_scope { order(updated_at: :desc) }

  def self.id_for_status(status_name)
    ProjectStatus.where('name = ?', status_name).first.id
  end
end