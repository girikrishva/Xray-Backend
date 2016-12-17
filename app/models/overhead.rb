class Overhead < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :department, class_name: 'Department', foreign_key: :department_id
  belongs_to :cost_adder_type, class_name: 'CostAdderType', foreign_key: :cost_adder_type_id

  validates :business_unit_id, presence: true
  validates :department_id, presence: true
  validates :cost_adder_type_id, presence: true
  validates :amount_date, presence: true
  validates :amount, presence: true

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :department_id, :cost_adder_type_id, :amount_date]
  validates_uniqueness_of :department_id, scope: [:business_unit_id, :department_id, :cost_adder_type_id, :amount_date]
  validates_uniqueness_of :cost_adder_type_id, scope: [:business_unit_id, :department_id, :cost_adder_type_id, :amount_date]
  validates_uniqueness_of :amount_date, scope: [:business_unit_id, :department_id, :cost_adder_type_id, :amount_date]

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end
end