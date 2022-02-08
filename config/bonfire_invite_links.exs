import Config

config :bonfire_invite_links,
  templates_path: "lib"

alias Bonfire.Invite.Links.Accounts

config :bonfire_invite_links, Accounts.Emails,
  confirm_email: [subject: "Confirm your email - Bonfire"],
  forgot_password: [subject: "Reset your password - Bonfire"]
