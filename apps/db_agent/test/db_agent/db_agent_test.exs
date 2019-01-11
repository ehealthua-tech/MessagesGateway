defmodule DbAgent.DbAgentTest do
  alias ContactsRequests
  alias OperatorsRequests
  alias OperatorTypesRequests
  use ExUnit.Case
  use DbAgent.DataCase

  test "database_test" do

    assert [] == DbAgent.OperatorTypesRequests.list_operator_types()
    new_operator_type = %{"active" => :true, "name" => "type_name", "priority" => 7}
    {:ok, created_operator_type} = DbAgent.OperatorTypesRequests.add_operator_type(new_operator_type)
    assert %{active: true, name: "type_name", priority: 7} ==
             %{active: created_operator_type.active, name: created_operator_type.name, priority: created_operator_type.priority}
    assert {1, nil} == DbAgent.OperatorTypesRequests.change_status(%{:id => created_operator_type.id, :active => :false, :name => "type_name", :priority => 7})
    DbAgent.OperatorTypesRequests.update_priority([%{"id" => created_operator_type.id, "priority" => 12, "active" => :false}])
    [updated_operator_type] = DbAgent.OperatorTypesRequests.list_operator_types()
    assert %{active: false, name: "type_name", priority: 12} ==
             %{active: updated_operator_type.active, name: updated_operator_type.name, priority: updated_operator_type.priority}
    assert updated_operator_type == DbAgent.OperatorTypesRequests.get_by_name("type_name")


    assert [] == DbAgent.OperatorsRequests.list_operators() #"bfa427e-be96-4c40-83df-f11c59c25df4" created_operator_type.id
    new_operator = %{"name" => "viber_test", "config" => %{"bla" => "bla"}, "priority" => 2, "price" => 12, "protocol_name" => "viber_protocol",
      "limit" => 100, "operator_type_id" => created_operator_type.id, "active" => :true}
    {:ok, created_operator} = DbAgent.OperatorsRequests.add_operator(new_operator)
    DbAgent.OperatorsRequests.get_by_name(created_operator.name)
   # {:ok, changed_operator} = DbAgent.OperatorsRequests.change_operator(created_operator.id, %{id: created_operator.id,
   #   name: "viber_test", config: %{"bla" => "bla"}, priority: 2, price: 14, limit: 100, protocol_name: "viber_protocol", active: :true})
    DbAgent.OperatorsRequests.operator_by_id(created_operator.id)
    DbAgent.OperatorsRequests.update_priority([%{"id" => created_operator_type.id, "priority" => 12, "active" => :false}])
    DbAgent.OperatorsRequests.operator_by_operator_type_id(created_operator_type.id)


    assert [] == DbAgent.ContactsRequests.list_contacts()
    new_contact = %{"phone_number" => "+380971112233", "viber_id" => "viber_id123", "operator_id" => created_operator_type.id}
    {:ok, created_contact} = DbAgent.ContactsRequests.add_contact(new_contact)
    assert %{operator_id: created_operator_type.id, phone_number: "+380971112233", viber_id: "viber_id123"} ==
             %{operator_id: created_contact.operator_id, phone_number: created_contact.phone_number, viber_id: created_contact.viber_id}
    {1, nil} == DbAgent.ContactsRequests.add_viber_id(%{:phone_number => "+380971112233", :viber_id => "viber_id1234", :operator_id => created_operator_type.id})
    {1, nil} == DbAgent.ContactsRequests.add_operator_id(%{:phone_number => "+380971112233", :viber_id => "viber_id1234", :operator_id => created_operator_type.id})
    updated_contact = DbAgent.ContactsRequests.get_by_phone_number!("+380971112233")
    assert %{id: created_contact.id, operator_id: created_operator_type.id, viber_id: "viber_id1234"} ==
             %{id: updated_contact.id, operator_id: updated_contact.operator_id, viber_id: updated_contact.viber_id}


    assert {1, nil} == DbAgent.OperatorTypesRequests.delete(created_operator_type.id)
    assert [] == DbAgent.OperatorTypesRequests.list_operator_types()
  end

end
