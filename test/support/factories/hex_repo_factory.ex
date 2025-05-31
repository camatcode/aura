# coveralls-ignore-start
defmodule Aura.Factory.HexRepoFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def hex_repo_factory(attrs) do
        inserted_at = Faker.DateTime.backward(40)

        %Aura.Model.HexRepo{
          name: Faker.Internet.user_name(),
          public: Enum.random([true, false]),
          active: Enum.random([true, false]),
          billing_active: Enum.random([true, false]),
          inserted_at: inserted_at,
          updated_at: Faker.DateTime.between(inserted_at, DateTime.now!("Etc/UTC"))
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end

# coveralls-ignore-stop
