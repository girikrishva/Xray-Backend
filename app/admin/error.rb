ActiveAdmin.register_page "Error" do
  menu false

  action_item only: :index do |resource|
    link_to "Back", :back
  end

  content title: proc { "Error" } do
    div class: "blank_slate_container", id: "error_default_message" do
      span class: "blank_slate" do
      end
    end
  end
end