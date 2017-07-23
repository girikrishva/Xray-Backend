class Skill < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :resources, class_name: 'Resource'
  has_many :staffing_requirements, class_name: 'StaffingRequirement'
  has_many :assigned_resources, class_name: 'AssignedResource'

# default_scope { order(updated_at: :desc) }
end