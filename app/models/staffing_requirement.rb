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

  before_create :date_check
  before_update :date_check

  def skill_name
    Skill.find(self.skill_id).name
  end

  def date_check
    if self.start_date > self.end_date
      raise I18n.t('errors.date_check')
    end
  end
end