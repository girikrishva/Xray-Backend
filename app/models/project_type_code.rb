class ProjectTypeCode < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :project_types, class_name: 'ProjectType'
end