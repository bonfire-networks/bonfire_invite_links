defmodule Bonfire.Invite.Links.Web.Test do
  use Bonfire.Invite.Links.ConnCase, async: true
  @moduletag :ui

  describe "generate an invite" do
    test "returns a flash confirmation" do
      some_account = fake_account!()

      {:ok, someone} =
        fake_user!(some_account)
        |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      next = "/settings/instance/invites"
      # |> debug
      # {view, doc} = floki_live(conn, next)
      {:ok, view, _html} = live(conn, next)

      assert submitted =
               view
               |> form("[data-id='generate_invite_link']")
               |> render_submit(%{
                 "invite_link" => %{"max_uses" => 7, "max_days_valid" => 1}
               })

      # |> find_flash()

      live_pubsub_wait(view)
      assert [flash] = find_flash(submitted)
      assert Floki.text(flash) =~ "New invite generated"
    end

    test "shows a new invite" do
      some_account = fake_account!()

      {:ok, someone} =
        fake_user!(some_account)
        |> Bonfire.Me.Users.make_admin()

      conn = conn(user: someone, account: some_account)

      next = "/settings/instance/invites"
      # |> debug
      {view, doc} = floki_live(conn, next)

      assert view
             |> form("[data-id='generate_invite_link']")
             |> render_submit(%{
               "invite_link" => %{"max_uses" => 5, "max_days_valid" => 1}
             })

      live_pubsub_wait(view)
      {:ok, view, _html} = live(conn, next)
      # open_browser(view)
      assert has_element?(view, "span", "in 24 hours")
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

      next = "/settings/instance/invites"
      {view, doc} = floki_live(conn, next)

      assert doc
             |> Floki.find("#invites_list tr")
             # |> debug
             |> Enum.count() == 2
    end
  end
end
