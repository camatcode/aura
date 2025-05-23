defmodule Aura.Factory.HexPackageFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def hex_package_factory(attrs) do
        inserted_at = Faker.DateTime.backward(40)
        meta = build(:package_meta)
        downloads = build(:package_downloads)
        releases = build_list(5, :hex_release)

        %Aura.Model.HexPackage{
          name: Faker.Internet.user_name(),
          repository: Faker.Internet.user_name(),
          private: Enum.random([true, false]),
          meta: meta,
          downloads: downloads,
          releases: releases,
          inserted_at: inserted_at,
          url: Faker.Internet.url(),
          html_url: Faker.Internet.url(),
          docs_html_url: Faker.Internet.url(),
          updated_at: Faker.DateTime.between(inserted_at, DateTime.now!("Etc/UTC"))
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end

      def package_meta_factory(attrs) do
        %Aura.Model.PackageMeta{
          maintainers: Enum.map(1..5, fn _ -> Faker.Internet.user_name() end),
          links: Enum.map(1..5, fn _ -> Faker.Internet.url() end),
          licenses: Enum.map(1..5, fn _ -> Faker.Internet.slug() end),
          description: Faker.Lorem.sentence()
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end

      def package_downloads_factory(attrs) do
        day = Faker.random_between(10, 100)
        week = day + Faker.random_between(10, 100)
        all = week + Faker.random_between(10, 100)

        %Aura.Model.DownloadStats{
          all: all,
          week: week,
          day: day
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
