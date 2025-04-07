defmodule Bonfire.Invite.Links.Web.Test do
  use Bonfire.Invite.Links.ConnCase, async: true
  @moduletag :ui

  describe "generate an invite" do
    test "returns a flash confirmation" do
      some_account = fake_account!()

      {:ok, someone} =
        fake_user!(some_account)
        |> Bonfire.Me.Users.make_admin()

      conn =
        conn(user: someone, account: some_account)
        |> visit("/settings/instance/invites")
        |> select("1", option: "Max number of uses")
        |> select("1 day", option: "Expire after")
        |> click_button("Generate a new invite link")
        |> assert_has("[role=alert]", text: "New invite generated!")
    end

    test "shows a new invite" do
      some_account = fake_account!()

      {:ok, someone} =
        fake_user!(some_account)
        |> Bonfire.Me.Users.make_admin()

      conn =
        conn(user: someone, account: some_account)
        |> visit("/settings/instance/invites")
        |> select("1", option: "Max number of uses")
        |> select("1 day", option: "Expire after")
        |> click_button("Generate a new invite link")
        |> assert_has("span", text: "tomorrow")
    end

    test "shows a list of invites" do
      some_account = fake_account!()

      {:ok, someone} =
        fake_user!(some_account)
        |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      Bonfire.Invite.Links.create(someone, %{
        "max_uses" => 1,
        "max_days_valid" => 1
      })

      Bonfire.Invite.Links.create(someone, %{
        "max_uses" => 1,
        "max_days_valid" => 1
      })

      conn
      |> visit("/settings/instance/invites")
      |> assert_has("#invites_list tr", count: 2)
    end

    test "delete an invites" do
      some_account = fake_account!()

      {:ok, someone} =
        fake_user!(some_account)
        |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      Bonfire.Invite.Links.create(someone, %{
        "max_uses" => 1,
        "max_days_valid" => 1
      })

      conn
      |> visit("/settings/instance/invites")
      |> click_button("[data-role=delete_invite]", "Delete")
      |> assert_has("[role=alert]", text: "Deleted")
      |> refute_has("#invites_list tr")
    end
  end
end
