defmodule Bonfire.Invite.Links.Web.InvitesLive do
  use Bonfire.UI.Common.Web, :stateful_component
  import Bonfire.Invite.Links

  prop invites, :list, default: []

  def update(_assigns, socket) do
    %{edges: invites, page_info: page_info} = list_paginated([], socket: socket)
    debug(invites, "mounting")

    {:ok,
     assign(
       socket,
       invites: invites,
       page_info: page_info,
       feed_update_mode: "append"
     )}
  end
end
