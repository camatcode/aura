defmodule Aura.Factory.HexReleaseFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def hex_release_factory(attrs) do
        name = Faker.Internet.slug()

        requirements =
          Enum.map(1..5, fn _ ->
            %{optional: Enum.random([true, false]), app: Faker.Internet.slug(), requirement: "~> #{Faker.App.semver()}"}
          end)

        meta = %{elixir: "~> 1.18", app: name, build_tools: ["mix"]}

        configs =
          %{
            "erlang.mk" => "#{name} = hex 0.9.2",
            "mix.exs" => "{:#{name}, \"~> 0.9.2\"}",
            "rebar.config" => "{#{name}, \"0.9.2\"}"
          }

        publisher =
          Enum.map(1..5, fn _ ->
            %{url: Faker.Internet.url(), email: Faker.Internet.email(), username: Faker.Internet.user_name()}
          end)

        inserted_at = Faker.DateTime.backward(40)
        has_docs = Enum.random([true, false])
        docs_html_url = if has_docs, do: Faker.Internet.url()
        retired? = Enum.random([true, false])

        retirement =
          if retired?,
            do: %{
              message: Faker.Lorem.sentence(),
              reason: Enum.random([:other, :invalid, :security, :deprecated, :renamed])
            }

        %Aura.Model.HexRelease{
          configs: configs,
          meta: meta,
          checksum: Faker.Lorem.characters(65),
          version: Faker.App.semver(),
          url: Faker.Internet.url(),
          docs_html_url: docs_html_url,
          html_url: Faker.Internet.url(),
          has_docs: has_docs,
          package_url: Faker.Internet.url(),
          downloads: Faker.random_between(10, 100),
          publisher: publisher,
          retirement: retirement,
          inserted_at: inserted_at,
          updated_at: Faker.DateTime.between(inserted_at, DateTime.now!("Etc/UTC"))
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
