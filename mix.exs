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
      test_coverage: [tool: ExCoveralls]
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
end
