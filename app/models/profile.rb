class Profile < ActiveRecord::Base
  self.table_name = 'admin_users'

# default_scope { order(updated_at: :desc) }
end