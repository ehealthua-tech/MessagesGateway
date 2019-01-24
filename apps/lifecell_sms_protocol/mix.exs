defmodule LifecellSmsProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :lifecell_sms_protocol,
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
      extra_applications: [:logger],
      mod: {LifecellSmsProtocol.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sweet_xml, "~> 0.6.5"},
      {:httpoison, "~> 1.4"},
      {:plug_cowboy, "~> 1.0"},
      {:amqp, "~> 1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
    ]
  end
end
