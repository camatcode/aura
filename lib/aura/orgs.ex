defmodule Aura.Orgs do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex Organizations")

  import Aura.Common

  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexOrg
  alias Aura.Model.HexOrgMember
  alias Aura.Requester

  @base_path "/orgs"

  @doc Aura.Doc.func_doc("Lists all the organizations the requester can see",
         params: %{opts: "option parameters used to modify requests"},
         success: "{:ok, [%HexOrg{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: @base_path, controller: :Organization, action: :index}
       )
  def list_orgs(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@base_path, opts) do
      {:ok, Enum.map(body, &HexOrg.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs an organization, given an **org_name**",
         params: %{org_name: "`t:Aura.Common.org_name/0`", opts: "option parameters used to modify requests"},
         success: "{:ok, %HexOrg{...}}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@base_path, ":org_name"), controller: :Organization, action: :show}
       )
  def get_org(org_name, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexOrg.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs a list of members to an organization, given an **org_name**",
         params: %{org_name: "`t:Aura.Common.org_name/0`", opts: "option parameters used to modify requests"},
         success: "{:ok, [%HexOrgMember{...}]}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@base_path, ":org_name/members"), controller: :OrganizationUser, action: :index}
       )
  def list_org_members(org_name, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexOrgMember.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs an org member, given their **org_name** and **username**",
         params: %{
           org_name: "`t:Aura.Common.org_name/0`",
           username: "`t:Aura.Common.username/0`",
           opts: "option parameters used to modify requests"
         },
         success: "{:ok, %HexOrgMember{...}}",
         failure: "{:error, (some error)}",
         api: %{
           route: Path.join(@base_path, ":org_name/members/:username"),
           controller: :OrganizationUser,
           action: :show
         }
       )
  def get_org_member(org_name, username, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/#{username}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexOrgMember.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Adds a user to an org with a given **role**",
         params: %{
           org_name: "`t:Aura.Common.org_name/0`",
           username: "`t:Aura.Common.username/0`",
           role: "`t:Aura.Model.HexOrgMember.role/0`",
           opts: "option parameters used to modify requests"
         },
         success: "{:ok, %HexOrgMember{...}}",
         failure: "{:error, (some error)}",
         api: %{
           method: :post,
           route: Path.join(@base_path, ":org_name/members/"),
           controller: :OrganizationUser,
           action: :create
         }
       )
  def add_org_member(org_name, username, role, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/")
    opts = Keyword.merge([json: %{organization: org_name, name: username, role: role}], opts)

    with {:ok, %{body: body}} <- Requester.post(path, opts) do
      {:ok, HexOrgMember.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Changes a user's role to **new_role**",
         params: %{
           org_name: "`t:Aura.Common.org_name/0`",
           username: "`t:Aura.Common.username/0`",
           new_role: "`t:Aura.Model.HexOrgMember.role/0`",
           opts: "option parameters used to modify requests"
         },
         success: "{:ok, %HexOrgMember{...}}",
         failure: "{:error, (some error)}",
         api: %{
           method: :post,
           route: Path.join(@base_path, ":org_name/members/:username"),
           controller: :OrganizationUser,
           action: :update
         }
       )
  def change_member_role(org_name, username, new_role, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/#{username}")
    opts = Keyword.merge([json: %{role: new_role}], opts)

    with {:ok, %{body: body}} <- Requester.post(path, opts) do
      {:ok, HexOrgMember.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Removes a user to an org",
         params: %{
           org_name: "`t:Aura.Common.org_name/0`",
           username: "`t:Aura.Common.username/0`",
           opts: "option parameters used to modify requests"
         },
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{
           method: :delete,
           route: Path.join(@base_path, ":org_name/members/:username"),
           controller: :OrganizationUser,
           action: :delete
         }
       )
  def remove_org_member(org_name, username, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/members/#{username}")

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Streams audit logs, scoped to an organization",
         params: %{"opts.page": "start from this page number"},
         success: "Stream.resource/3",
         api: %{route: Path.join(@base_path, ":org_name/audit-logs"), controller: :Organization, action: :audit_logs}
       )
  @spec stream_audit_logs(opts :: list()) :: Enumerable.t()
  def stream_audit_logs(org_name, opts \\ []) do
    path = Path.join(@base_path, "#{org_name}/audit-logs")
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
