class AdminUsersSession < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id

  def admin_user_details
    'User: [' + self.admin_user.name + '], Email: [' + self.admin_user.email + ']'
  end
end