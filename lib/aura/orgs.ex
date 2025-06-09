defmodule Aura.Orgs do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex Organizations")

  import Aura.Common

  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexOrg
  alias Aura.Model.HexOrgMember
  alias Aura.Requester

  @base_path "/orgs"

  @typedoc Aura.Doc.type_doc("Options to modify an Orgs request",
             keys: %{
               repo_url: Aura.Common
             }
           )
  @type org_opts :: [repo_url: Aura.Common.repo_url()]

  @doc Aura.Doc.func_doc("Lists all the organizations the requester can see",
         params: [{"opts[:repo_url]", {Aura.Common, :repo_url}}],
         success: "{:ok, [%HexOrg{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: @base_path, controller: :Organization, action: :index},
         example: """
         iex> alias Aura.Orgs
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, orgs} = Orgs.list_orgs(opts)
         iex> Enum.empty?(orgs)
         false
         """
       )
  @spec list_orgs(opts :: org_opts()) :: {:ok, [HexOrg.t()]} | {:error, any()}
  def list_orgs(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@base_path, opts) do
      {:ok, Enum.map(body, &HexOrg.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs an organization, given an **org_name**",
         params: [{:org_name, {Aura.Common, :org_name}}, {"opts[:repo_url]", {Aura.Common, :repo_url}}],
         success: "{:ok, %HexOrg{...}}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@base_path, ":org_name"), controller: :Organization, action: :show},
         example: """
         iex> alias Aura.Orgs
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, org} = Orgs.get_org("test_org", opts)
         iex> org.name
         "test_org"
         """
       )
  @spec get_org(org_name :: Aura.Common.org_name(), opts :: org_opts()) :: {:ok, HexOrg.t()} | {:error, any()}
  def get_org(org_name, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexOrg.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs a list of members to an organization, given an **org_name**",
         params: [{:org_name, {Aura.Common, :org_name}}, {"opts[:repo_url]", {Aura.Common, :repo_url}}],
         success: "{:ok, [%HexOrgMember{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@base_path, ":org_name/members"), controller: :OrganizationUser, action: :index},
         example: """
         iex> alias Aura.Orgs
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, members} = Orgs.list_org_members("test_org", opts)
         iex> Enum.empty?(members)
         false
         """
       )
  @spec list_org_members(org_name :: Aura.Common.org_name(), opts :: org_opts()) ::
          {:ok, HexOrgMember.t()} | {:error, any()}
  def list_org_members(org_name, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexOrgMember.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs an org member, given their **org_name** and **username**",
         params: [
           {:org_name, {Aura.Common, :org_name}},
           {:username, {Aura.Common, :username}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, %HexOrgMember{...}}",
         failure: "{:error, (some error)}",
         api: %{
           route: Path.join(@base_path, ":org_name/members/:username"),
           controller: :OrganizationUser,
           action: :show
         },
         example: """
         iex> alias Aura.Orgs
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, member} = Orgs.get_org_member("test_org", "testuser", opts)
         iex> member.username
         "testuser"
         """
       )
  @spec get_org_member(org_name :: Aura.Common.org_name(), username :: Aura.Common.username(), opts :: org_opts()) ::
          {:ok, HexOrgMember.t()} | {:error, any()}
  def get_org_member(org_name, username, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/#{username}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexOrgMember.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Adds a user to an org with a given **role**",
         params: [
           {:org_name, {Aura.Common, :org_name}},
           {:username, {Aura.Common, :username}},
           {:role, {Aura.Model.HexOrgMember, :role}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, %HexOrgMember{...}}",
         failure: "{:error, (some error)}",
         api: %{
           method: :post,
           route: Path.join(@base_path, ":org_name/members/"),
           controller: :OrganizationUser,
           action: :create
         }
       )
  @spec add_org_member(
          org_name :: Aura.Common.org_name(),
          username :: Aura.Common.username(),
          role :: Aura.Model.HexOrgMember.role(),
          opts :: org_opts()
        ) :: {:ok, HexOrgMember.t()} | {:error, any()}
  def add_org_member(org_name, username, role, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/")
    opts = Keyword.merge([json: %{organization: org_name, name: username, role: role}], opts)

    with {:ok, %{body: body}} <- Requester.post(path, opts) do
      {:ok, HexOrgMember.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Changes a user's role to **new_role**",
         params: [
           {:org_name, {Aura.Common, :org_name}},
           {:username, {Aura.Common, :username}},
           {:new_role, {Aura.Model.HexOrgMember, :role}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, %HexOrgMember{...}}",
         failure: "{:error, (some error)}",
         api: %{
           method: :post,
           route: Path.join(@base_path, ":org_name/members/:username"),
           controller: :OrganizationUser,
           action: :update
         }
       )
  @spec change_member_role(
          org_name :: Aura.Common.org_name(),
          username :: Aura.Common.username(),
          new_role :: Aura.Model.HexOrgMember.role(),
          opts :: org_opts
        ) :: {:ok, HexOrgMember.t()} | {:error, any()}
  def change_member_role(org_name, username, new_role, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/#{username}")
    opts = Keyword.merge([json: %{role: new_role}], opts)

    with {:ok, %{body: body}} <- Requester.post(path, opts) do
      {:ok, HexOrgMember.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Removes a user from an org",
         params: [
           {:org_name, {Aura.Common, :org_name}},
           {:username, {Aura.Common, :username}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{
           method: :delete,
           route: Path.join(@base_path, ":org_name/members/:username"),
           controller: :OrganizationUser,
           action: :delete
         }
       )
  @spec remove_org_member(org_name :: Aura.Common.org_name(), username :: Aura.Common.username(), opts :: org_opts()) ::
          :ok | {:error, any()}
  def remove_org_member(org_name, username, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/#{username}")

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc(
         [
           "Streams audit logs, scoped to an organization",
           "Note that the page size is fixed by the API to be 100 per page."
         ],
         params: [
           {:org_name, {Aura.Common, :org_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}},
           {"opts[:page]", {Aura.Common, :start_page}}
         ],
         params: %{"opts.page": "start from this page number"},
         success: "Stream.resource/3",
         api: %{route: Path.join(@base_path, ":org_name/audit-logs"), controller: :Organization, action: :audit_logs},
         example: """
         iex> alias Aura.Orgs
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> [first, _second] = Orgs.stream_audit_logs("test_org", opts) |> Enum.take(2)
         iex> String.starts_with?(first.user_agent, "aura")
         true
         """
       )
  @spec stream_audit_logs(org_name :: Aura.Common.org_name(), opts :: Aura.Common.audit_opts()) :: Enumerable.t()
  def stream_audit_logs(org_name, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/audit-logs")
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
