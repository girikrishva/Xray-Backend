class ProjectTypeCode < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :project_types, class_name: 'ProjectType'
  has_many :pipelines, class_name: 'Pipeline'
  has_many :pipelines_audits, class_name: 'PipelinesAudit'
  has_many :projects, class_name: 'Project'

# default_scope { order(updated_at: :desc) }
end