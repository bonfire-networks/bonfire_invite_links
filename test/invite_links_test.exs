defmodule Bonfire.Invite.Links.Test do
  use Bonfire.Invite.Links.ConnCase, async: true

  test "can create an invite" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 2})

    assert invite.max_uses == 1
    assert invite.max_days_valid == 2

  end

  test "can list invites" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 2})
    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 3, "max_days_valid" => 4})

    %{edges: invites} = Bonfire.Invite.Links.list_paginated([], current_user: someone)
    # |> debug()

    assert Enum.count(invites) == 2

  end

  test "can check that an invite is valid and can be redeemed" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 2})

    assert invite |> Bonfire.Invite.Links.redeemable?() == true

  end


  test "can check that an invite is invalid and cannot be redeemed" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 0, "max_days_valid" => 2})

    assert invite |> Bonfire.Invite.Links.redeemable?() == false

  end

  test "can check that an invite didn't expire" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 2})

    assert invite |> Bonfire.Invite.Links.expired?() == false

  end

  test "can display an invite's relative expiry date" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 2})

    assert invite |> Bonfire.Invite.Links.date_expires() |> date_relative() == "tomorrow"

  end

  test "can redeem an invite" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 2})

    Bonfire.Invite.Links.redeem(invite)

    %{edges: invites} = Bonfire.Invite.Links.list_paginated([], current_user: someone)
    assert List.first(invites).max_uses == 0

  end

  test "cannot redeem an invalid invite" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => 1, "max_days_valid" => 2})

    Bonfire.Invite.Links.redeem(invite)

    %{edges: invites} = Bonfire.Invite.Links.list_paginated([], current_user: someone)

    assert_raise(RuntimeError, fn -> List.first(invites) |> Bonfire.Invite.Links.redeem() end)

  end

  test "redeem works with unlimited use invites" do

    some_account = fake_account!()
    {:ok, someone} = fake_user!(some_account)
              |> Bonfire.Me.Users.make_admin()

    conn = conn(user: someone, account: some_account)

    {:ok, invite} = Bonfire.Invite.Links.create(someone, %{"max_uses" => "", "max_days_valid" => 2})

    Bonfire.Invite.Links.redeem(invite)
    %{edges: invites} = Bonfire.Invite.Links.list_paginated([], current_user: someone)
    assert List.first(invites).max_uses == nil
  end

end
