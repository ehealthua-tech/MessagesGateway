defmodule ViberProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :viber_protocol,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/dev.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ViberProtocol.Application, []},
      extra_applications: [:logger,  :plug_cowboy]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:db_agent, in_umbrella: true},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 1.0"},
      {:redix, ">= 0.0.0"},
      {:amqp, "~> 1.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
