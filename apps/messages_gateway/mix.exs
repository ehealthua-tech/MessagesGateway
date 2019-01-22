defmodule MessagesGateway.Mixfile do
  use Mix.Project

  def project do
    [
      app: :messages_gateway,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:ex_unit]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MessagesGateway.Application, []},
      extra_applications: [:logger, :runtime_tools, :amqp]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:db_agent, in_umbrella: true},

      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:amqp, "~> 1.1.0"},
      {:eview, "~> 0.12"},
      {:redix, ">= 0.0.0"},
      {:jason, "~> 1.1"},
      {:plug_logger_json, "~> 0.5"},
      {:plug_cowboy, "~> 1.0"},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:mox, "~> 0.3", only: :test},
      {:ex_machina, "~> 2.0", only: [:dev, :test]}
    ]
  end
end
