defmodule MgLogger do

  def log_message(module, payload) do
    url = Application.get_env(:mg_logger, :elasticsearch_url)
    lowercase_string_module = String.downcase(to_string(module))
    payload_with_date = Map.put(payload, "date", DateTime.to_string(DateTime.utc_now()))
    any = HTTPoison.post(Enum.join([url, "/log_", lowercase_string_module,"/log"]), Jason.encode!(payload_with_date), [{"Content-Type", "application/json"}])
    :io.format("~n~n~nAny:~p~n",[any])
    :io.format("~n~n~nAny:~p~n",[to_string(__MODULE__)])
  end
end
