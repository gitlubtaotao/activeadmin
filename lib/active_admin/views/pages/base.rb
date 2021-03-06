module ActiveAdmin
  module Views
    module Pages
      class Base < Arbre::HTML::Document
				
        def build(*args)
	        if request.format.js?
		        return build_collection
	        end
	        set_attribute :lang, I18n.locale
          build_active_admin_head
          build_page
        end

        alias_method :html_title, :title # Arbre::HTML::Title
        def title
          self.class.name
        end

        def main_content
          I18n.t('active_admin.main_content', model: title).html_safe
        end

        private

        delegate :active_admin_config, :controller, :params, to: :helpers

        def build_active_admin_head
          within head do
            html_title [title, helpers.active_admin_namespace.site_title(self)].compact.join(" | ")

            text_node(active_admin_namespace.head)

            active_admin_application.stylesheets.each do |style, options|
              text_node stylesheet_link_tag(style, options).html_safe
            end

            active_admin_namespace.meta_tags.each do |name, content|
              text_node(tag(:meta, name: name, content: content))
            end

            active_admin_application.javascripts.each do |path|
              text_node(javascript_include_tag(path))
            end

            # if active_admin_namespace.favicon
            #   text_node(favicon_link_tag(active_admin_namespace.favicon))
            # end

            text_node csrf_meta_tag
          end
        end

        def build_page
	        
          within body(class: body_classes) do
	          
            div id: "wrapper" do
              build_unsupported_browser
              build_menu
              title_bar title, action_items_for_action
              build_page_content
              footer active_admin_namespace
            end
	          div id: 'top-back',class: 'top-back' do
	          end
          end
        end
        def build_menu
	        div class: 'head_nav' do
		        menu_content = red.get("menu_content_#{current_user.id}")
		        if menu_content.present?
			        text_node(menu_content.html_safe)
		        else
			        content = header active_admin_namespace, current_menu
			        red.set("menu_content_#{current_user.id}", content.to_s,ex: (Time.now.at_end_of_day - Time.now).to_i)
		        end
	        end
        end
						

        def body_classes
          Arbre::HTML::ClassList.new [
            params[:action],
            params[:controller].tr('/', '_'),
            'active_admin', 'logged_in',
            active_admin_namespace.name.to_s + '_namespace'
          ]
        end

        def build_unsupported_browser
          if active_admin_namespace.unsupported_browser_matcher =~ controller.request.user_agent
            unsupported_browser
          end
        end

        def build_page_content
          build_flash_messages
          div id: "active_admin_content", class: (skip_sidebar? ? "without_sidebar" : "with_sidebar") do
            # sidebar sidebar_sections_for_action, id: 'sidebar' unless skip_sidebar?
            build_main_content_wrapper
          end
        end

        def build_flash_messages
          div class: 'flashes' do
            flash_messages.each do |type, message|
              div message, class: "flash flash_#{type}"
            end
          end
        end

        def build_main_content_wrapper
          div id: "main_content_wrapper" do
            div id: "main_content" do
              main_content
            end
          end
        end




        # Returns the sidebar sections to render for the current action
        def sidebar_sections_for_action
          if active_admin_config && active_admin_config.sidebar_sections?
            active_admin_config.sidebar_sections_for(params[:action], self)
          else
            []
          end
        end

        def action_items_for_action
          if active_admin_config && active_admin_config.action_items?
            active_admin_config.action_items_for(params[:action], self)
          else
            []
          end
        end

        def skip_sidebar?
          sidebar_sections_for_action.empty? || assigns[:skip_sidebar] == true
        end

      end
    end
  end
end
