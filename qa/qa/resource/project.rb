# frozen_string_literal: true

require 'securerandom'

module QA
  module Resource
    class Project < Base
      attribute :name
      attribute :description

      attribute :group do
        Group.fabricate!
      end

      attribute :repository_ssh_location do
        Page::Project::Show.perform do |page|
          page.choose_repository_clone_ssh
          page.repository_location
        end
      end

      attribute :repository_http_location do
        Page::Project::Show.perform do |page|
          page.choose_repository_clone_http
          page.repository_location
        end
      end

      def initialize
        @description = 'My awesome project'
      end

      def name=(raw_name)
        @name = "#{raw_name}-#{SecureRandom.hex(8)}"
      end

      def fabricate!
        group.visit!

        Page::Group::Show.perform(&:go_to_new_project)

        Page::Project::New.perform do |page|
          page.choose_test_namespace
          page.choose_name(@name)
          page.add_description(@description)
          page.set_visibility('Public')
          page.create_new_project
        end
      end

      def api_get_path
        "/projects/#{name}"
      end

      def api_post_path
        '/projects'
      end

      def api_post_body
        {
          namespace_id: group.id,
          path: name,
          name: name,
          description: description,
          visibility: 'public'
        }
      end

      private

      def transform_api_resource(api_resource)
        api_resource[:repository_ssh_location] =
          Git::Location.new(api_resource[:ssh_url_to_repo])
        api_resource[:repository_http_location] =
          Git::Location.new(api_resource[:http_url_to_repo])
        api_resource
      end
    end
  end
end
