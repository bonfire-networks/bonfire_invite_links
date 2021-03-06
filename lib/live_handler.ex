defmodule Bonfire.Invite.Links.LiveHandler do
  use Bonfire.UI.Common.Web, :live_handler
  import Where

  def handle_event("generate", %{"invite_link" => attrs}, socket) do
    # info(socket, "attrs")
    with {:ok, invite} <-  Bonfire.Invite.Links.create(current_user(socket), attrs) do
      socket =
        socket
        |> assign_flash(:info, "New invite generated!")
      {:noreply, socket
      |> assign(
        invites: [invite], #++ e(socket, :assigns, :invites, []),
          feed_update_mode: "prepend"
          )
        }
    end
  end

  def handle_event("load_more", attrs, socket) do
    debug(attrs, "attrs")
    with %{edges: invites, page_info: page_info} <-  Bonfire.Invite.Links.list_paginated([], current_user: current_user(socket), paginate: attrs) do
      # debug(invites)
      {:noreply, socket
        |> assign(
          invites: invites,
          feed_update_mode: "append"
        )
        |> assign(page_info: page_info)
      }
    end
  end
end
