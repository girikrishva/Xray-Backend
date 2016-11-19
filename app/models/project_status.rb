class ProjectStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :projects, class_name: 'Project'
end