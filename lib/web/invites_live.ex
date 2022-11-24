defmodule Bonfire.Invite.Links.Web.InvitesLive do
  use Bonfire.UI.Common.Web, :stateful_component
  import Bonfire.Invite.Links

  prop invites, :list, default: []

  def update(assigns, socket) do
    %{edges: invites, page_info: page_info} = list_paginated([], socket: socket)

    {:ok,
     assign(
       socket,
       invites: invites,
       page_info: page_info,
       feed_update_mode: "append"
     )}
  end

  def handle_event(
        action,
        attrs,
        socket
      ),
      do:
        Bonfire.UI.Common.LiveHandlers.handle_event(
          action,
          attrs,
          socket,
          __MODULE__
          # &do_handle_event/3
        )

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
end
