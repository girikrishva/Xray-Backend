class Pipeline < ActiveRecord::Base
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :client, class_name: 'Client', foreign_key: :client_id
  belongs_to :pipeline_status, class_name: 'PipelineStatus', foreign_key: :pipeline_status_id
  belongs_to :project_type_code, class_name: 'ProjectTypeCode', foreign_key: :project_type_code_id

  validates :business_unit_id, presence: true
  validates :client_id, presence: true
  validates :pipeline_status_id, presence: true
  validates :project_type_code_id, presence: true
  validates :name, presence: true
  validates :expected_start, presence: true
  validates :expected_end, presence: true
  validates :expected_value, presence: true

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :client_id]
  validates_uniqueness_of :client_id, scope: [:business_unit_id, :client_id]

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end
end