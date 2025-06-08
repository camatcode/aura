defmodule Aura.OrgsTest do
  use ExUnit.Case

  alias Aura.Orgs

  @moduletag :capture_log
  doctest Orgs

  setup do
    TestHelper.setup_state()
  end

  test "orgs", %{other_users: other_users} do
    {:ok, key} = Aura.APIKeys.create_api_key("test_user_key", "test@test.com", "elixir1234", true)
    Application.put_env(:aura, :api_key, key.secret)
    {:ok, orgs} = Orgs.list_orgs()
    refute Enum.empty?(orgs)

    Enum.each(orgs, fn org ->
      {:ok, retrieved} = Orgs.get_org(org.name)
      assert retrieved.name

      Enum.each(other_users, fn other_user ->
        {:ok, org_member} = Orgs.add_org_member(org.name, other_user.username, :read)
        assert org_member.username == other_user.username
        {:ok, updated} = Orgs.change_member_role(org.name, org_member.username, :write)
        assert updated.role == "write"
        :ok = Orgs.remove_org_member(org.name, other_user.username)
      end)

      audit_logs = Orgs.stream_audit_logs(org.name)
      refute Enum.empty?(audit_logs)
      Enum.each(audit_logs, fn audit_log -> assert audit_log.action end)

      {:ok, members} = Orgs.list_org_members(org.name)
      refute Enum.empty?(members)

      Enum.each(members, fn member ->
        {:ok, member} = Orgs.get_org_member(org.name, member.username)
        assert member.username
      end)
    end)
  end
end
