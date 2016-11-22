class Skill < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :resources, class_name: 'Resource'
  has_many :staffing_requirements, class_name: 'StaffingRequirement'
end