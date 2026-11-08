defmodule Bonfire.Invite.Links.Web.Test do
  use Bonfire.Invite.Links.ConnCase, async: System.get_env("TEST_UI_ASYNC") != "no"
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
        |> select("Max number of uses", option: "1")
        |> select("Expire after", option: "1 day")
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
        |> select("Max number of uses", option: "1")
        |> select("Expire after", option: "1 day")
        |> click_button("Generate a new invite link")
        |> assert_has_or("span", [text: "tomorrow"], fn session ->
          session
          |> assert_has("span", text: "in 24 hours")
        end)
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

  # each choice of the "Expire after" menu must store as many days as its label says
  describe "the \"Expire after\" choices" do
    for {label, days} <- [
          {"Never", nil},
          {"1 day", 1},
          {"2 days", 2},
          {"1 week", 7},
          {"2 weeks", 14},
          {"1 month", 28},
          {"6 months", 182},
          {"1 year", 365}
        ] do
      test "\"#{label}\" makes an invite valid for #{inspect(days)} days" do
        some_account = fake_account!()

        {:ok, someone} =
          fake_user!(some_account)
          |> Bonfire.Me.Users.make_admin()

        conn(user: someone, account: some_account)
        |> visit("/settings/instance/invites")
        |> select("Max number of uses", option: "1")
        |> select("Expire after", option: unquote(label))
        |> click_button("Generate a new invite link")
        |> assert_has("[role=alert]", text: "New invite generated!")

        assert {:ok, invite} = Bonfire.Invite.Links.one([])
        assert invite.max_days_valid == unquote(days)
      end
    end
  end
end
