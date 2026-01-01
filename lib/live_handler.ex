defmodule Bonfire.Invite.Links.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler
  import Untangle

  def handle_event("generate", %{"invite_link" => attrs}, socket) do
    with {:ok, invite} <-
           Bonfire.Invite.Links.create(current_user_required!(socket), attrs) do
      {:noreply,
       socket
       |> assign_flash(:info, "New invite generated!")
       |> stream_insert(:invites, invite, at: 0)}
    end
  end

  def handle_event("delete", %{"invite" => id}, socket) do
    with {:ok, _} <-
           Bonfire.Invite.Links.delete(id, current_user: current_user_required!(socket)) do
      {:noreply,
       socket
       |> assign_flash(:info, "Deleted")
       |> stream_delete(:invites, %{id: id})}
    end
  end

  def handle_event("load_more", attrs, socket) do
    with %{edges: invites, page_info: page_info} <-
           Bonfire.Invite.Links.list_paginated([],
             current_user: current_user(socket),
             paginate: attrs
           ) do
      {:noreply,
       socket
       |> stream(:invites, invites)
       |> assign(page_info: page_info)}
    end
  end
end
