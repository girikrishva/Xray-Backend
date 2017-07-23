class AdminUsersSession < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id

# default_scope { order(updated_at: :desc) }

  def admin_user_details
    'User: [' + self.admin_user.name + '], Email: [' + self.admin_user.email + ']'
  end

  def session_length
    session_seconds = self.session_ended - self.session_started
    Time.at(session_seconds).utc.strftime("%H:%M:%S:[%L]") rescue 0
  end

  def avg_session_length
    sessions = AdminUsersSession.where('admin_user_id = ? and id <= ?', self.admin_user_id, self.id)
    session_seconds = 0.0
    session_count = 0.0
    sessions.each do |s|
      session_seconds += (s.session_ended - s.session_started)
      session_count += 1.0
    end
    Time.at(session_seconds / session_count).utc.strftime("%H:%M:%S:[%L]") rescue 0
  end

  def min_session_length
    sessions = AdminUsersSession.where('admin_user_id = ? and id <= ?', self.admin_user_id, self.id)
    min_session_seconds = 1000000000.0
    sessions.each do |s|
      session_seconds = s.session_ended - s.session_started
      if session_seconds <= min_session_seconds
        min_session_seconds = session_seconds
      end
    end
    Time.at(min_session_seconds).utc.strftime("%H:%M:%S:[%L]") rescue 0
  end

  def max_session_length
    sessions = AdminUsersSession.where('admin_user_id = ? and id <= ?', self.admin_user_id, self.id)
    max_session_seconds = 0.0
    sessions.each do |s|
      session_seconds = s.session_ended - s.session_started
      if session_seconds >= max_session_seconds
        max_session_seconds = session_seconds
      end
    end
    Time.at(max_session_seconds).utc.strftime("%H:%M:%S:[%L]") rescue 0
  end
end