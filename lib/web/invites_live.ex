defmodule Bonfire.Invite.Links.Web.InvitesLive do
  use Bonfire.UI.Common.Web, :stateful_component
  import Bonfire.Invite.Links

  prop invites, :list, default: []

  def update(_assigns, socket) do
    %{edges: invites, page_info: page_info} = list_paginated([], socket: socket)
    debug(invites, "mounting")

    {:ok,
     socket
     |> stream(:invites, invites)
     |> assign(page_info: page_info)}
  end
end
