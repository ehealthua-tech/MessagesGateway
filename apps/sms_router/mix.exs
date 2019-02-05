defmodule SmsRouter.MixProject do
  use Mix.Project

  def project do
    [
      app: :sms_router,
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
      mod: {SmsRouter.Application, []},
      extra_applications: [:logger]

    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [

        {:db_agent, in_umbrella: true},
        {:jason, "~> 1.1"},
        {:redix, ">= 0.0.0"}
    ]
  end
end
