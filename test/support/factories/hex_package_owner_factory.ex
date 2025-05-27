defmodule Aura.Factory.HexPackageOwnerFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def hex_package_owner_factory(attrs) do
        #    :handles,
        #  ]

        inserted_at = Faker.DateTime.backward(40)

        %Aura.Model.HexPackageOwner{
          email: Faker.Internet.email(),
          full_name: Faker.Person.name(),
          inserted_at: inserted_at,
          level: Enum.random([:maintainer, :full]),
          updated_at: Faker.DateTime.between(inserted_at, DateTime.now!("Etc/UTC")),
          url: Faker.Internet.url(),
          username: Faker.Internet.user_name()
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
