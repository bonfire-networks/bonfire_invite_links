defmodule Bonfire.InviteLink do

  use Pointers.Pointable,
    otp_app: :bonfire_invite_links,
    table_id: "1NV1TE11NKF0RJ01N1NGB0NF1R",
    source: "bonfire_invite_link"

  alias Bonfire.InviteLink
  alias Ecto.Changeset

  pointable_schema do
    field :max_uses, :integer
    field :max_days_valid, :integer
  end

  @cast [:max_uses, :max_days_valid]

  def changeset(obj \\ %InviteLink{}, params) do
    obj
    |> Changeset.cast(params, @cast)
  end

end

defmodule Bonfire.Invites.Link.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.InviteLink

  def up() do
    Pointers.Migration.create_pointable_table(Bonfire.InviteLink) do
      Ecto.Migration.add :max_uses, :integer
      Ecto.Migration.add :max_days_valid, :integer
    end
  end

  def down(), do: drop_if_exists(table(InviteLink))

end
