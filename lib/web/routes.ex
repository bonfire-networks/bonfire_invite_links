defmodule Bonfire.Invite.Links.Web.Routes do
  @behaviour Bonfire.UI.Common.RoutesModule

  defmacro __using__(_) do
    quote do
      # pages anyone can view
      scope "/", Bonfire.Invite.Links.Web do
        pipe_through(:browser)
      end

      # pages only guests can view
      scope "/", Bonfire.Invite.Links.Web do
        pipe_through(:browser)
        pipe_through(:guest_only)
      end

      scope "/", Bonfire do
        pipe_through(:browser)
        pipe_through(:account_required)
      end

      # pages you need an account to view
      scope "/", Bonfire.Invite.Links.Web do
        pipe_through(:browser)
        pipe_through(:account_required)
      end

      # pages you need to view as a user
      scope "/", Bonfire.Invite.Links.Web do
        pipe_through(:browser)
        pipe_through(:user_required)
      end

      # pages only admins can view
      scope "/settings", Bonfire.Invite.Links.Web do
        pipe_through(:browser)
        pipe_through(:admin_required)
      end
    end
  end
end
