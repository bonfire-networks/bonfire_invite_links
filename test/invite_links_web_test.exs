defmodule Bonfire.Invite.Links.Web.Test do

  use Bonfire.Social.ConnCase


  describe "generate an invite" do

    test "returns a flash confirmation" do

      some_account = fake_account!()
      {:ok, someone} = fake_user!(some_account)
                |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      next = "/settings/admin/invites"
      {view, doc} = floki_live(conn, next) #|> debug
      assert view
      |> form("[data-id='generate_invite_link']")
      |> render_submit(%{"invite_link" => %{"max_uses" => 0, "max_days_valid" =>0}})
      |> Floki.text() =~ "New invite generated"

    end

    test "shows a new invite" do

      some_account = fake_account!()
      {:ok, someone} = fake_user!(some_account)
                |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      next = "/settings/admin/invites"
      {view, doc} = floki_live(conn, next) #|> debug
      assert view
      |> form("[data-id='generate_invite_link']")
      |> render_submit(%{"invite_link" => %{"max_uses" => 1, "max_days_valid" => 1}})
      |> Floki.text() =~ "11d"

    end

    test "shows a list of invites" do

      some_account = fake_account!()
      {:ok, someone} = fake_user!(some_account)
                |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 1})
      Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 1})
      Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 1})
      Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 1})

      next = "/settings/admin/invites"
      {view, doc} = floki_live(conn, next)

      assert view
      |> Floki.find("table tr")
      |> debug
      |> Enum.count == 4

    end
  end

end
