class ProjectOverhead < ActiveRecord::Base
  belongs_to :project, class_name: 'Project', foreign_key: :project_id
  belongs_to :cost_adder_type, class_name: 'CostAdderType', foreign_key: :cost_adder_type_id

  validates :project_id, presence: true
  validates :cost_adder_type_id, presence: true
  validates :amount_date, presence: true
  validates :amount, presence: true

  validates_uniqueness_of :project_id, scope: [:project_id, :cost_adder_type_id, :amount_date]
  validates_uniqueness_of :cost_adder_type_id, scope: [:project_id, :cost_adder_type_id, :amount_date]
  validates_uniqueness_of :amount_date, scope: [:project_id, :cost_adder_type_id, :amount_date]
end