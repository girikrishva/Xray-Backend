class DeliveryMilestone < ActiveRecord::Base
  belongs_to :project, class_name: 'Project', foreign_key: :project_id

  validates :project_id, presence: true
  validates :name, presence: true
  validates :due_date, presence: true

  validates_uniqueness_of :project_id, scope: [:project_id, :name, :due_date]
  validates_uniqueness_of :name, scope: [:project_id, :name, :due_date]
  validates_uniqueness_of :due_date, scope: [:project_id, :name, :due_date]
end