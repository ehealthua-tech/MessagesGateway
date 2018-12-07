defmodule MessagesGatewayWeb.AdminView do
  use MessagesGatewayWeb, :view

  def render("system_config.json", %{config: system_config}) do
    %{
      config: system_config
    }
  end

  def render("change_system_config.json", %{:status => status}) do
    %{
      message: status
    }
  end

  def render("operator_types.json", %{operator_types: operator_types}) do
    render_many(operator_types, __MODULE__, "show_operator_types.json")
  end

  def render("change_operator_type.json", %{:status => status}) do
    %{
      message: status
    }
  end

  def render("operators.json", %{:operators => operators}) do
    render_many(operators, __MODULE__, "show_operator.json")
  end

  def render("change_operator.json", %{:status => status}) do
    %{
      message: status
    }
  end

  def render("show_operator_types.json", %{operator_type: operator_type}) do
    %{
      id: operator_type.id,
      name: operator_type.name,
      active: operator_type.active,
      last_update: operator_type.last_update
    }
  end

  def render("show_operator.json", %{operator: operator}) do
    %{
      id: operator.id,
      operator_name: operator.name,
      operator_type_id: operator.operator_type_id,
      operator_config: operator.config,
      priority: operator.priority,
      price: operator.price,
      limit: operator.limit,
      active: operator.active,
      last_update: operator.last_update
    }
  end

end