class Role < ActiveRecord::Base
  has_many :admin_users, class_name: 'AdminUser'

  validates :name, presence: true
  validates :rank, presence: true

  validates_uniqueness_of :name
  validates_uniqueness_of :rank

  def self.generate_next_rank
    Role.all.order(:rank).last.rank + 1
  end
end