defmodule DbAgent.DbAgentTest do
  @moduledoc """
    Module for db_agent tests
  """

  alias ContactsRequests
  alias OperatorsRequests
  alias OperatorTypesRequests
  use ExUnit.Case
  use DbAgent.DataCase

  @doc """
    Run tests for operator_types, operators and contacts
  """
  test "database_test" do
    assert [] == DbAgent.OperatorTypesRequests.list_operator_types()
    new_operator_type = %{:active => :true, :name => "type_name"}
    {:ok, created_operator_type} = DbAgent.OperatorTypesRequests.add_operator_type(new_operator_type)
    assert %{active: true, name: "type_name", priority: 1} ==
             %{active: created_operator_type.active, name: created_operator_type.name, priority: created_operator_type.priority}
    assert {1, nil} == DbAgent.OperatorTypesRequests.change_status(%{:id => created_operator_type.id, :active => :false, :name => "type_name", "priority" => 1})
    DbAgent.OperatorTypesRequests.update_priority([%{"id" => created_operator_type.id, "priority" => 12, "active" => :false}])
    [updated_operator_type] = DbAgent.OperatorTypesRequests.list_operator_types()
    assert %{active: false, name: "type_name", priority: 12} ==
             %{active: updated_operator_type.active, name: updated_operator_type.name, priority: updated_operator_type.priority}
    assert updated_operator_type == DbAgent.OperatorTypesRequests.get_by_name("type_name")


    assert [] == DbAgent.OperatorsRequests.list_operators()
    new_operator = %{"name" => "viber_test", "config" => %{"bla" => "bla"}, "price" => 12, "protocol_name" => "viber_protocol",
      "limit" => 100, "operator_type_id" => created_operator_type.id, "active" => :true}
    {:ok, created_operator} = DbAgent.OperatorsRequests.add_operator(new_operator)
    DbAgent.OperatorsRequests.get_by_name(created_operator.name)
    {1, nil} = DbAgent.OperatorsRequests.change_operator(created_operator.id, [id: created_operator.id,
      name: "viber_test", config: %{"bla" => "bla"}, price: 14, limit: 100, protocol_name: "viber_protocol", active: :true])
    DbAgent.OperatorsRequests.operator_by_id(created_operator.id)
    DbAgent.OperatorsRequests.update_priority([%{"id" => created_operator_type.id, "priority" => 12, "active" => :false}])
    DbAgent.OperatorsRequests.update_priority([%{id: created_operator_type.id, priority: 12, active: :false}])
    DbAgent.OperatorsRequests.operator_by_operator_type_id(created_operator_type.id)
    DbAgent.OperatorsRequests.calc_priority(%{"name" => "test", "price" => 12})


    assert [] == DbAgent.ContactsRequests.list_contacts()
    new_contact = %{"phone_number" => "+380971112233", "viber_id" => "viber_id123", "operator_id" => created_operator.id}
    {:ok, created_contact} = DbAgent.ContactsRequests.add_contact(new_contact)
    assert %{operator_id: created_operator.id, phone_number: "+380971112233", viber_id: "viber_id123"} ==
             %{operator_id: created_contact.operator_id, phone_number: created_contact.phone_number, viber_id: created_contact.viber_id}
    assert {1, nil} == DbAgent.ContactsRequests.add_viber_id(%{:phone_number => "+380971112233", :viber_id => "viber_id1234", :operator_id => created_operator.id})
    assert {1, nil} == DbAgent.ContactsRequests.add_operator_id(%{:phone_number => "+380971112233", :viber_id => "viber_id1234", :operator_id => created_operator.id})
    {:ok, res} = DbAgent.ContactsRequests.add_viber_id(%{:phone_number => "+380971112237", :viber_id => "viber_id1234", :operator_id => created_operator.id})
    assert res.phone_number == "+380971112237"
    updated_contact = DbAgent.ContactsRequests.get_by_phone_number!("+380971112233")
    updated_contact2 = DbAgent.ContactsRequests.get_by_phone_number!("+380971112237")
    assert %{id: created_contact.id, operator_id: created_operator.id, viber_id: "viber_id1234"} ==
             %{id: updated_contact.id, operator_id: updated_contact.operator_id, viber_id: updated_contact.viber_id}

    assert {:error, changeset} = DbAgent.ContactsRequests.add_contact(%{"id" => 1234})
    assert ["can't be blank"] = errors_on(changeset).phone_number

    assert {1, nil} == DbAgent.ContactsRequests.delete(created_contact.id)
    assert {1, nil} == DbAgent.ContactsRequests.delete(updated_contact2.id)
    assert {1, nil} == DbAgent.OperatorsRequests.delete(created_operator.id)
    assert {1, nil} == DbAgent.OperatorTypesRequests.delete(created_operator_type.id)



  end

end
