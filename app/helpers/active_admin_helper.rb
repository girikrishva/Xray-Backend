module ActiveAdminHelper

  # make this method public (compulsory)
  def self.included(dsl)
    # nothing ...
  end

  def is_authorized?(allowed_roles)
    if allowed_roles.blank?
      return true
    end
    allowed_roles.each do |allowed_role|
      if Role.where(name: allowed_role).first.id == current_admin_user.role_id
        return true
      end
      allowed_role_ancestry = Role.where(name: allowed_role).first.ancestor_ids
      if allowed_role_ancestry.include?(current_admin_user.role_id)
        return true
      end
    end
    return false
  end
end