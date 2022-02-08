defmodule Bonfire.Invite.Links.Fake do

  alias Bonfire.Me.Fake, as: MeFake

  # import Bonfire.Invite.Links.Integration

  defdelegate fake_account!(attrs \\ %{}, opts \\ []), to: MeFake

  defdelegate fake_user!(attrs \\ %{}, opts \\ []), to: MeFake

end
