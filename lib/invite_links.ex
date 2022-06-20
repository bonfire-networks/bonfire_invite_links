defmodule Bonfire.Invite.Links do
  use Bonfire.Common.Repo
  alias Bonfire.InviteLink
  use Bonfire.Common.Utils
  use Arrows

  def create(user, attrs) do
    repo().transact_with(fn ->
      with {:ok, invite} <- repo().insert(InviteLink.changeset(attrs)) do

        {:ok, invite}
      end
    end)
  end

  def redeem(%InviteLink{} = invite) do
    if !redeemable?(invite), do: raise l "Sorry, this invite is no longer valid."

    from(r in InviteLink,
      update: [inc: [max_uses: -1]],
      where: r.id == ^invite.id
    )
    |> repo().update_all([])
  end
  def redeem(invite_id) when is_binary(invite_id) do
    get(invite_id) ~> redeem()
  end
  def redeem(_) do
    nil
  end

  def query(filters, _opts \\ []) do
    InviteLink
    |> query_filter(filters)
  end

  def one(filters, opts \\ []) do
    query(filters, opts)
    |> repo().single()
  end

  def get(id, opts \\ []) do
    if is_ulid?(id), do: one([id: id], opts)
  end

  def list_paginated(filters, opts \\ []) do

    query(filters, opts)
      |> Bonfire.Common.Repo.many_paginated(opts[:paginate]) # return a page of items (reverse chronological) + pagination metadata
  end

  def redeemable?(%InviteLink{} = invite) do
    (is_nil(invite.max_uses) or invite.max_uses > 0)
      and !expired?(invite)
  end

  def redeemable?(invite_id) when is_binary(invite_id) do
    one(id: invite_id) ~> redeemable?()
  end

  def date_expires(%InviteLink{} = invite) do
    created = Utils.date_from_pointer(invite) |> dump

    if invite.max_days_valid && invite.max_days_valid > 0 do
      expiry_date = DateTime.add(created, invite.max_days_valid*24*60*60, :second)
    end
  end

  def expired?(%InviteLink{} = invite) do
    created = Utils.date_from_pointer(invite) #|> dump
    date_expires = date_expires(invite) #|> dump

    if date_expires do
      case DateTime.compare(date_expires, created) do
        :gt -> false # expiry_date > created == not expired
        _other -> true
      end
    else # no limit
      false
    end
  end
end
