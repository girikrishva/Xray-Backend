class StaffingRequirement < ActiveRecord::Base
  belongs_to :pipeline, class_name: 'Pipeline', foreign_key: :pipeline_id
  belongs_to :skill, :class_name => 'Skill', :foreign_key => :skill_id
  belongs_to :designation, :class_name => 'Designation', :foreign_key => :designation_id

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :number_required, presence: true
  validates :hours_per_day, presence: true
  validates :pipeline_id, presence: true
  validates :skill_id, presence: true
  validates :designation_id, presence: true

  def skill_name
    Skill.find(self.skill_id).name
  end
end