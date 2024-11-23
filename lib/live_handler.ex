defmodule Bonfire.Invite.Links.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler
  import Untangle

  def handle_event("generate", %{"invite_link" => attrs}, socket) do
    with {:ok, invite} <-
           Bonfire.Invite.Links.create(current_user_required!(socket), attrs) do
      invites = [invite | e(assigns(socket), :invites, [])]

      {:noreply,
       socket
       |> assign_flash(:info, "New invite generated!")
       |> assign(
         # ++ e(assigns(socket), :invites, []),
         invites: invites,
         feed_update_mode: "prepend"
       )}
    end
  end

  def handle_event("delete", %{"invite" => id}, socket) do
    with {:ok, _} <-
           Bonfire.Invite.Links.delete(id, current_user: current_user_required!(socket)) do
      invites =
        e(assigns(socket), :invites, [])
        |> debug("dddd")
        # Remove the invite with matching id
        |> Enum.reject(fn %{id: i_id} -> i_id == id end)
        |> debug()

      {:noreply,
       socket
       |> assign_flash(:info, "Deleted")
       |> assign(
         feed_update_mode: "replace",
         invites: invites
       )}
    end
  end

  def handle_event("load_more", attrs, socket) do
    # debug(attrs, "attrs")

    with %{edges: invites, page_info: page_info} <-
           Bonfire.Invite.Links.list_paginated([],
             current_user: current_user(assigns(socket)),
             paginate: attrs
           ) do
      # debug(invites)
      {:noreply,
       socket
       |> assign(
         invites: invites,
         feed_update_mode: "append"
       )
       |> assign(page_info: page_info)}
    end
  end
end
