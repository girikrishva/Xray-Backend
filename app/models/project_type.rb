class ProjectType < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :project_type_code, class_name: 'ProjectTypeCode', foreign_key: :project_type_code_id

  validates :business_unit_id, presence: true
  validates :project_type_code_id, presence: true

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :project_type_code_id]
  validates_uniqueness_of :project_type_code_id, scope: [:business_unit_id, :project_type_code_id]

# default_scope { order(updated_at: :desc) }

  def business_unit_name
    self.business_unit.name
  end
end