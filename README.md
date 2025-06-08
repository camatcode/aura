<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/camatcode/aura/refs/heads/main/assets/aura-logo-dark.png">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/camatcode/aura/refs/heads/main/assets/aura-logo-light.png">
    <img alt="aura logo" src="https://raw.githubusercontent.com/camatcode/aura/refs/heads/main/assets/aura-logo-light.png" width="720">
  </picture>
</p>

<p align="center" id="top">
  An ergonomic library for investigating the Hex.pm API
</p>

<p align="center">
  <a href="https://hex.pm/packages/aura">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/aura.svg">
  </a>
  <a href="https://hexdocs.pm/aura">
    <img alt="Hex Docs" src="http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat">
  </a>
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img alt="Apache 2 License" src="https://img.shields.io/hexpm/l/aura">
  </a>
  <a href="https://github.com/camatcode/aura/actions?query=branch%3Amain++">
    <img alt="ci status" src="https://github.com/camatcode/aura/workflows/ci/badge.svg">
  </a>
  <a href='https://coveralls.io/github/camatcode/aura?branch=main'>
    <img src='https://coveralls.io/repos/github/camatcode/aura/badge.svg?branch=main' alt='Coverage Status' />
  </a>
  <a href="https://scorecard.dev/viewer/?uri=github.com/camatcode/aura" target="_blank" rel="noopener noreferrer">
    <img alt="OpenSSF Scorecard" src="https://api.scorecard.dev/projects/github.com/camatcode/aura/badge">
  </a>
  <a href="https://www.bestpractices.dev/projects/10689">
    <img src="https://www.bestpractices.dev/projects/10689/badge">
  </a> 
  <a href="https://mastodon.social/@scrum_log" target="_blank" rel="noopener noreferrer">
    <img alt="Mastodon Follow" src="https://img.shields.io/badge/mastodon-%40scrum__log%40mastodon.social-purple?color=6364ff">
  </a>
</p>

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Smoke Test](#smoke-test)
- [Implementation Overview](#implementation-overview)
    - [Domains](#domains)
- [Testing](#testing)
- [FAQ](#faq)

## Installation

Add `:aura` to your list of deps in `mix.exs`:

```elixir
{:aura, "~> 1.0"}
```

Then run `mix deps.get` to install Aura and its dependencies.

## Configuration

```elixir
config :aura,
  # The hex-compliant backend for Aura to connect to
  # This can also be passed in as an option to all service functions
  # Default: https://hex.pm/api
  # See "Testing" for other options
  repo_url: System.get_env("AURA_REPO_URL", "http://localhost:4000/api"),
  # API secret payload to use when making requests from the hex-compliant backend
  # This cannot be passed in as an option to service functions.
  # Please: Don't put the actual secret payload as plain text in your code.
  # Default: nil
  api_key: System.get_env("HEX_API_KEY")

```

## Smoke Test

```elixir
# Grab aura
{:ok, package} = Aura.Packages.get_package("aura")
latest_version = package.releases |> hd() |> Map.get(:version)
# Grab aura's latest release
{:ok, release} = Aura.Releases.get_release("aura", latest_version)
{:ok,
 %Aura.Model.HexRelease{
   checksum: "8fb6919a3cf545b10e09bc9b98169cca82468157a5e6b1ebd754e833934b02dd",
   configs: %{
     "erlang.mk" => "dep_aura = hex 0.9.1",
     "mix.exs" => "{:aura, \"~> 0.9.1\"}",
     "rebar.config" => "{aura, \"0.9.1\"}"
   },
   docs_html_url: "https://hexdocs.pm/aura/0.9.1/",
   has_docs: true,
   html_url: "https://hex.pm/packages/aura/0.9.1",
   inserted_at: ~U[2025-06-04 04:51:30.142335Z],
   meta: %{elixir: "~> 1.18", app: "aura", build_tools: ["mix"]},
   package_url: "https://hex.pm/api/packages/aura",
   publisher: %{
     url: "https://hex.pm/api/users/camatcode",
     email: "cam.cook.codes@gmail.com",
     username: "camatcode"
   },
   requirements: [
     %{app: "date_time_parser", optional: false, requirement: "~> 1.2.0"},
     %{app: "proper_case", optional: false, requirement: "~> 1.3"},
     %{app: "req", optional: false, requirement: "~> 0.5.10"}
   ],
   retirement: nil,
   updated_at: ~U[2025-06-04 04:51:33.602905Z],
   version: "0.9.1",
   url: "https://hex.pm/api/packages/aura/releases/0.9.1",
   downloads: 0
 }}
```

## Implementation Overview

### Domains

| Domain       | Hex API Controller                                                                                                          | Aura Equivalant | Implemented Actions                             | Notes                                       |
|--------------|-----------------------------------------------------------------------------------------------------------------------------|-----------------|-------------------------------------------------|---------------------------------------------|
| API Key      | [KeyController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/key_controller.ex)                   | `Aura.APIKeys`  | list, get, create, delete, delete all           | Can be scoped to an organization            |
| Organization | [OrganizationController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/organization_controller.ex) | `Aura.Orgs`     | list, get, audit                                |                                             |
| ∟ Org User   | [OrganizationUser](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/organization_user_controller.ex)  | "               | list, get, add, change role, remove             |                                             |
| Package      | [PackageController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/package_controller.ex)           | `Aura.Packages` | stream packages, get, audit                     | Can be scoped to a repo                     |
| ∟ Owner      | [OwnerController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/owner_controller.ex)               | "               | list, get, add, remove                          | Can be scoped to a repo                     |
| Release      | [ReleaseController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/release_controller.ex)           | `Aura.Releases` | publish, get, retire, un-retire, delete         | Can be scoped to a repo                     |
| ∟ Doc        | [DocsController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/docs_controller.ex)                 | "               | publish, get, delete                            | Can be scoped to a repo                     |
| Repository   | [RepositoryController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/repository_controller.ex)     | `Aura.Repos`    | list, get                                       |                                             |
| User         | [UserController](https://github.com/hexpm/hexpm/blob/main/lib/hexpm_web/controllers/api/user_controller.ex)                 | `Aura.Users`    | create, get, get current, reset password, audit | Read `create` docs carefully for ToS caveat |

## Testing

> [!WARNING]
> All Aura tests expect to connect to a local hex instance
> and will **purposely crash** if it discovers it's testing against hex.pm.

You should be very mindful about issuing requests against a production hex API.

To make this easy, you can `docker compose up -d` from the root of this repository to launch a local instance
of [hexpm/hexpm](https://github.com/camatcode/hex_tiny?tab=readme-ov-file#hex_beefy) and set the `repo_url`
to http://localhost:4000/api in [Configuration](#configuration).

```bash
➜  docker compose up -d
[+] Running 1/1
 ✔ Container hex_beefy  Started                                                                                  0.1s 
➜  curl http://localhost:4000/api | jq
{
  "documentation_url": "http://docs.hexpm.apiary.io",
  "key_url": "http://localhost:4000/api/keys/{name}",
  "keys_url": "http://localhost:4000/api/keys",
  "package_owners_url": "http://localhost:4000/api/packages/{name}/owners",
  "package_release_url": "http://localhost:4000/api/packages/{name}/releases/{version}",
  "package_url": "http://localhost:4000/api/packages/{name}",
  "packages_url": "http://localhost:4000/api/packages"
}
```

## FAQ

> Why not use hex_core?

Fantastic question! I'd say for most cases, you should just use hex_core, or the associated Mix tasks to interact with
Hex. But here are a couple of motivations for using Aura.

1. hex_core can be intimidating to folks without a strong erlang background.
2. Aura is meant to be friendly to Elixir folks.
3. Aura's aim is to be [documented](https://hexdocs.pm/aura) *to hell and back*.
4. The maintainer has larger plans that would use Aura as a base.



