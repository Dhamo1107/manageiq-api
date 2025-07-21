module Api
  class ContainerGroupsController < BaseController
    def create_resource(type, _id, data = {})
      create_ems_resource(type, data) do |ems, klass|
        {:task_id => klass.create_container_pod_queue(User.current_userid, ems, data)}
      end
    end

    def edit_resource(type, id, data = {})
      api_resource(type, id, "Updating") do |container_group|
        {:task_id => container_group.update_container_pod_queue(User.current_userid, data)}
      end
    end

    def delete_resource_main_action(type, container_group, _data)
      ensure_respond_to(type, container_group, :delete, :delete_container_pod_queue)
      {:task_id => container_group.delete_container_pod_queue(User.current_userid)}
    end

    def check_compliance_resource(type, id, _data = nil)
      enqueue_ems_action(type, id, "Check Compliance for", :method_name => "check_compliance", :supports => true)
    end

    def get_metadata_resource(type, id, data = {})
      container_group = resource_search(id, :container_groups, ContainerGroup)

      # Get metadata from Kubernetes
      metadata = container_group.get_pod_metadata

      {
        :id => container_group.id,
        :name => container_group.name,
        :container_project => {
          :id => container_group.container_project&.id,
          :name => container_group.container_project&.name
        },
        :ext_management_system => {
          :id => container_group.ext_management_system&.id,
          :name => container_group.ext_management_system&.name
        },
        :labels => metadata[:labels],
        :annotations => metadata[:annotations]
      }
    rescue => err
      action_result(false, err.to_s)
    end
  end
end
