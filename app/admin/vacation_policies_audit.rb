ActiveAdmin.register VacationPoliciesAudit do
  menu false

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_vacation_policies_path
  end

  config.sort_order = 'id_desc'

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :vacation_code
    column :description
    column :as_on
    column :paid
    column :days_allowed
    column :comments
    column :audit_details
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Administrator"])
    end

    before_filter only: :index do |resource|
      if !params.has_key?(:vacation_policy_id)
        redirect_to admin_vacation_policies_path
      end
      if params[:commit].blank? && params[:q].blank?
        extra_params = {"q" => {"vacation_policy_id_eq" => params[:vacation_policy_id]}}
        # make sure data is filtered and filters show correctly
        params.merge! extra_params
      end
    end

    def scoped_action
      VacationPoliciesAudit.includes [:vacation_code, :business_unit, :vacation_policy]
    end
  end

  filter :description
  filter :as_on
  filter :paid
  filter :days_allowed
  filter :comments
  filter :updated_at
  filter :updated_by
  filter :ip_address
end
