# coveralls-ignore-start
defmodule Aura.Factory.HexAPIKeyFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def hex_api_key_factory(attrs) do
        inserted_at = Faker.DateTime.backward(40)

        permissions = [
          %{
            domain: "api",
            resource: "read"
          }
        ]

        %Aura.Model.HexAPIKey{
          authing_key: Enum.random([true, false]),
          name: Faker.Internet.slug(),
          permissions: permissions,
          inserted_at: inserted_at,
          url: Faker.Internet.url(),
          updated_at: Faker.DateTime.between(inserted_at, DateTime.now!("Etc/UTC"))
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end

# coveralls-ignore-stop
