defmodule Bonfire.Invite.Links.Web.Test do
  use Bonfire.Invite.Links.ConnCase, async: true

  describe "generate an invite" do

    test "returns a flash confirmation" do

      some_account = fake_account!()
      {:ok, someone} = fake_user!(some_account)
                |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      next = "/settings/invites"
      {view, doc} = floki_live(conn, next) #|> debug

      assert submitted = view
      |> form("[data-id='generate_invite_link']")
      |> render_submit(%{"invite_link" => %{"max_uses" => 7, "max_days_valid" => 1}})
      # |> find_flash()

      live_pubsub_wait(view)
      assert [flash] = find_flash(submitted)
      assert Floki.text(flash) =~ "New invite generated"
    end

    test "shows a new invite" do

      some_account = fake_account!()
      {:ok, someone} = fake_user!(some_account)
                |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      next = "/settings/invites"
      {view, doc} = floki_live(conn, next) #|> debug
      assert view
      |> form("[data-id='generate_invite_link']")
      |> render_submit(%{"invite_link" => %{"max_uses" => 5, "max_days_valid" => 1}})
      |> Floki.text() =~ "23 hours"
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

      next = "/settings/invites"
      {view, doc} = floki_live(conn, next)

      assert doc
      |> Floki.find("#invites_list tr")
      # |> debug
      |> Enum.count == 4
    end
  end

end
