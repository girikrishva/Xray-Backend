ActiveAdmin.register VacationPoliciesAudit do
  menu false

  config.clear_action_items!

  scope I18n.t('label.deleted'), if: proc { current_admin_user.role.super_admin }, default: false do |resources|
    VacationPoliciesAudit.only_deleted.where('vacation_policy_id = ?', params[:vacation_policy_id]).order('id desc')
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.all'), admin_vacation_policies_audits_path(vacation_policy_id: params[:vacation_policy_id])
  end

  action_item only: :index do |resource|
    link_to I18n.t('label.back'), admin_vacation_policies_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), :back
  end

  batch_action :destroy, if: proc { params[:scope] != 'deleted' } do |ids|
    vacation_policy_id = VacationPoliciesAudit.without_deleted.find(ids.first).vacation_policy_id
    ids.each do |id|
      object = VacationPoliciesAudit.destroy(id)
      if !object.errors.empty?
        flash[:error] = object.errors.full_messages.to_sentence
        break
      end
    end
    redirect_to admin_vacation_policies_audits_path(vacation_policy_id: vacation_policy_id)
  end

  batch_action :restore, if: proc { params[:scope] == 'deleted' } do |ids|
    vacation_policy_id = VacationPoliciesAudit.with_deleted.find(ids.first).vacation_policy_id
    ids.each do |id|
      VacationPoliciesAudit.restore(id)
    end
    redirect_to admin_vacation_policies_audits_path(vacation_policy_id: vacation_policy_id)
  end

  config.sort_order = 'id_desc'

  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    column :vacation_code
    column :description
    column :as_on
    column :paid
    column :days_allowed do |element|
      div :style => "text-align: right;" do
        number_with_precision element.days_allowed, precision: 1, delimiter: ','
      end
    end
    column :comments
    column :audit_details
    actions defaults: false, dropdown: true do |resource|
      item I18n.t('actions.view'), admin_vacation_policies_audit_path(resource.id)
    end
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

    before_filter :skip_sidebar!, if: proc { params.has_key?(:scope) }

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
