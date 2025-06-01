defmodule Aura.MixProject do
  use Mix.Project

  @source_url "https://github.com/camatcode/aura"
  @version "0.9.0"

  def project do
    [
      app: :aura,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ],
      # Hex
      package: package(),
      description: """
      An ergonomic library for investigating the Hex.pm API
      """,

      # Docs
      name: "Aura",
      docs: [
        main: "Aura",
        api_reference: false,
        logo: "assets/aura-logo.png",
        source_ref: "v#{@version}",
        source_url: @source_url,
        extra_section: "GUIDES",
        formatters: ["html"],
        extras: extras(),
        groups_for_modules: groups_for_modules(),
        skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
      ]
    ]
  end

  defp groups_for_modules do
    [
      Services: [
        Aura.Packages,
        Aura.Releases,
        Aura.Repos
      ],
      Model: [
        Aura.Model.HexAPIKey,
        Aura.Model.HexAuditLog,
        Aura.Model.HexPackage,
        Aura.Model.HexPackageDownloadStats,
        Aura.Model.HexPackageMeta,
        Aura.Model.HexPackageOwner,
        Aura.Model.HexRelease,
        Aura.Model.HexRepo,
        Aura.Model.HexUser
      ],
      Common: [
        Aura.PackageTarUtil,
        Aura.Requester,
        Aura.Model.Common,
        Aura.Common
      ]
    ]
  end

  def package do
    [
      maintainers: ["Cam Cook"],
      licenses: ["Apache-2.0"],
      files: ~w(lib .formatter.exs .credo.exs mix.exs README* CHANGELOG* LICENSE*),
      links: %{
        Website: @source_url,
        Changelog: "#{@source_url}/blob/master/CHANGELOG.md",
        GitHub: @source_url
      }
    ]
  end

  def extras do
    [
      "README.md"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.37", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_license, "~> 0.1.0", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: [:test]},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.8.0", only: :test},
      {:faker, "~> 0.18.0", only: :test},
      {:junit_formatter, "~> 3.1", only: [:test]},
      {:req, "~> 0.5.10"},
      {:proper_case, "~> 1.3"},
      {:date_time_parser, "~> 1.2.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
