# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :radioapp,
  ecto_repos: [Radioapp.Repo],
  admin_tenant: "admin",
  super_admin_role: "super_admin"

# Configures the endpoint
config :radioapp, RadioappWeb.Endpoint,
  url: [host: "nvlocal.net"],
  render_errors: [
    formats: [html: RadioappWeb.ErrorHTML, json: RadioappWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Radioapp.PubSub,
  live_view: [signing_salt: "2jlv8atB"],
  check_origin: [
    "//*.radioapp.ca",
    "//demo.northernvillage.com"
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :radioapp, Radioapp.Mailer, adapter: Swoosh.Adapters.Local

# in case want to test on dev
# config :radioapp, Radioapp.Mailer,
# adapter: Swoosh.Adapters.Sendgrid,
# api_key: {:system, "SENDGRID_API_KEY"}

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure the CORS plugin
config :cors_plug,
  origin: ["http://localhost:4000/", "https://demo.radioapp.ca/"],
  max_age: 86400,
  methods: ["GET"],
  send_preflight_response?: false

config :ex_aws,
  json_codec: Jason,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key_id: {:system, "AWS_SECRET_ACCESS_KEY_ID"}

config :triplex,
  repo: Radioapp.Repo,
  tenant_prefix: "org_"

config :appsignal, :config,
  otp_app: :radioapp,
  name: "radioapp",
  push_api_key: System.get_env("APPSIGNAL_PUSH_API_KEY"),
  env: Mix.env(),
  active: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
