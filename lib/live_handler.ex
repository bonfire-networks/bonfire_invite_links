defmodule Bonfire.Invite.Links.LiveHandler do
  use Bonfire.Web, :live_handler

  def handle_event("generate", %{"invite_link" => attrs}, socket) do
    debug(attrs, "attrs")
    with {:ok, invite} <-  Bonfire.Invite.Links.create(current_user(socket), attrs) do
      debug(invite)
      {:noreply, socket
        |> assign(invites: [invite] ++ e(socket, :assigns, :invites, []) )
        |> put_flash(:info, l "New invite generated!")
        }
    end
  end

  def handle_event("load_more", attrs, socket) do
    debug(attrs, "attrs")
    with %{edges: invites, page_info: page_info} <-  Bonfire.Invite.Links.list_paginated([], current_user: current_user(socket), paginate: attrs) do
      debug(invites)
      {:noreply, socket
        |> assign(invites: invites)
        |> assign(page_info: page_info)
      }
    end
  end
end
