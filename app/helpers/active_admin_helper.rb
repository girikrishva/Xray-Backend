module ActiveAdminHelper

  # make this method public (compulsory)
  def self.included(dsl)
    # nothing ...
  end

  def is_authorized?(allowed_roles, disallowed_roles = [])
    if allowed_roles.blank? and disallowed_roles.blank?
      return true
    end
    allowed_roles.each do |allowed_role|
      if Role.where(name: allowed_role).first.id == current_admin_user.role_id
        return is_not_authorized(disallowed_roles) & true
      end
      allowed_role_ancestry = Role.where(name: allowed_role).first.ancestor_ids
      if allowed_role_ancestry.include?(current_admin_user.role_id)
        return is_not_authorized(disallowed_roles) & true
      end
    end
    return false
  end

  private

  def is_not_authorized(disallowed_roles)
    if disallowed_roles.blank?
      return true
    end
    disallowed_roles.each do |disallowed_role|
      if Role.where(name: disallowed_role).first.id == current_admin_user.role_id
        return false
      end
    end
    return true
  end
end