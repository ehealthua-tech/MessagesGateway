defmodule MessagesGatewayWeb.OperatorsView do
  use MessagesGatewayWeb, :view

  def render("index.json",%{operators: operators}) do
    render_many(operators, __MODULE__, "operator.json")
  end

  def render("create.json", %{status: insert_status}) do
    %{status: insert_status}
  end

  def render("delete.json", %{status: delete_status}) do
    %{status: delete_status}
  end

  def render("protocols.json", %{protocols: protocols}) do
    %{protocols: protocols}
  end

  def render("operator.json", %{operators: %{operator: operator, operator_type: operator_type}}) do
    %{
      id: operator.id,
      name: operator.name,
      operator_type:
        %{id: operator_type.id,
          name: operator_type.name,
          active: operator_type.active
        },
      config: operator.config,
      priority: operator.priority,
      price: operator.price,
      limit: operator.limit,
      active: operator.active,
      last_update: operator.updated_at
    }
  end

  def render("show.json",%{operator: operator}) do
    %{
      id: operator.id,
      name: operator.name,
      operator_type_id: operator.operator_type_id,
      config: operator.config,
      priority: operator.priority,
      price: operator.price,
      limit: operator.limit,
      active: operator.active,
      last_update: operator.updated_at
    }
  end

end