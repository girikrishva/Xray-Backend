module ActiveAdminHelper

  # make this method public (compulsory)
  def self.included(dsl)
    # nothing ...
  end

  def is_authorized?(allowed_roles)
    current_role = Role.find(current_admin_user.role_id).name
    if allowed_roles.blank? or allowed_roles.include?(current_role)
      return true
    else
      return false
    end
  end

  def is_not_authorized?(disallowed_roles)
    current_role = Role.find(current_admin_user.role_id).name
    if disallowed_roles.blank? or !disallowed_roles.include?(current_role)
      return true
    else
      return false
    end
  end
end