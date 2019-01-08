defmodule MessagesGatewayWeb.OperatorTypeView do
  use MessagesGatewayWeb, :view

  def render("index.json",%{operator_types: operator_types}) do
    render_many(operator_types, __MODULE__, "operator_type.json")
  end

  def render("create.json", %{status: insert_status}) do
    %{status: insert_status}
  end

  def render("delete.json", %{status: delete_status}) do
    %{status: delete_status}
  end

  def render("operator_type.json", %{operator_type: operator_type}) do
    %{
      id: operator_type.id,
      name: operator_type.name,
      active: operator_type.active,
      priority: operator_type.priority,
      last_update: operator_type.updated_at
    }
  end
end