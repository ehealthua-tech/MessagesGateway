defmodule MessagesGateway.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixir: "1.7.4",
      erlang_otp: "21.0",
      dialyzer: [plt_add_apps: [:ex_unit]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      aliases: aliases()
    ]
  end


  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:distillery, "~> 1.5", runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: [:dev, :test]},
      {:credo, "~> 1.0", only: [:dev, :test]}
    ]
  end

  def aliases do
    [
      messages_router_test: "cmd --app messages_router mix test --color",
      messages_router_coveralls: ["cmd --app messages_router mix coveralls.html --color"],
      messages_gateway_test: "cmd --app messages_gateway mix test --color",
      messages_gatewa_coveralls: ["cmd --app messages_gateway mix coveralls.html --color"],
      db_agent_test: "cmd --app db_agent mix test --color",
      db_agent_coveralls: ["cmd --app db_agent mix coveralls.html --color"]
    ]
  end
end

