# coveralls-ignore-start
defmodule Aura.Factory.HexUserFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def hex_user_factory(attrs) do
        inserted_at = Faker.DateTime.backward(40)

        %Aura.Model.HexUser{
          username: Faker.Internet.user_name(),
          email: Faker.Internet.email(),
          url: Faker.Internet.url(),
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
