ActiveAdmin.register_page "Error" do
  menu false

  action_item only: :index do |resource|
    if params.has_key?(:back_path)
      link_to "Back", params[:back_path].to_s
    else
      link_to "Back", :back
    end
  end

  content title: proc { "Error" } do
    div class: "blank_slate_container", id: "error_default_message" do
      span class: "blank_slate" do
      end
    end
  end
end