defmodule Bonfire.Invite.Links do
  use Bonfire.Repo

  def create(user, attrs) do

    repo().transact_with(fn ->
      with {:ok, invite} <- repo().insert(Bonfire.InviteLink.changeset(attrs)) do

        {:ok, invite}
      end
    end)
  end


  def list_paginated(filters, opts \\ [], query \\ Bonfire.InviteLink) do

    query
      |> query_filter(filters)
      |> Bonfire.Repo.many_paginated(opts[:paginate]) # return a page of items (reverse chronological) + pagination metadata
  end
end
