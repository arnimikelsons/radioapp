defmodule RadioappWeb.Router do
  use RadioappWeb, :router

  import RadioappWeb.UserAuth
  alias RadioappWeb.EnsureRolePlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RadioappWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user

    plug RadioappWeb.AllowIFramePlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug :fetch_api_user
  end

  pipeline :user do
    plug EnsureRolePlug, [:user, :admin, :super_admin]
  end

  pipeline :admin do
    plug EnsureRolePlug, [:admin, :super_admin]
  end

  pipeline :super_admin do
    plug EnsureRolePlug, [:super_admin]
  end

  pipeline :api_admin do
    plug EnsureRolePlug, [:admin]
  end

  pipeline :tenant_in_session do
    plug RadioappWeb.Plugs.SessionTenant
  end

  # Other scopes may use custom stacks.
  scope "/api", RadioappWeb do
     pipe_through :api
    # Set up API requests from client websites to display now playing show
    get "/shows", Api.ProgramApiController, :show
  end

  scope "/api", RadioappWeb do
    pipe_through :api_auth
   # Handle authenticated API requests from playout software to add segments to log
   resources "/songs", Api.SongController
 end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:radioapp, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RadioappWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", RadioappWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :tenant_in_session]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{RadioappWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      #live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end


  scope "/", RadioappWeb do
    pipe_through [:browser, :require_authenticated_user, :user, :tenant_in_session]

    live_session :require_authenticated_user,
      on_mount: [{RadioappWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", RadioappWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{RadioappWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
      live "/users/accept/:token", UserAcceptanceLive, :edit
      live "/users/accept", UserAcceptanceInstructionsLive, :new

    end
  end

  scope "/", RadioappWeb do
    pipe_through [:browser, :super_admin]

    resources "/orgs", OrgController
  end

  scope "/", RadioappWeb do
    pipe_through [:browser, :require_authenticated_user, :user]

    get "/users", UserController, :index
    get "/users/:id/edit", UserController, :edit
    patch "/users/:id", UserController, :update
    put "/users/:id", UserController, :update

    get "/programs/:id/edit", ProgramController, :edit
    get "/programs/new", ProgramController, :new
    post "/programs", ProgramController, :create
    patch "/programs/:id", ProgramController, :update
    put "/programs/:id", ProgramController, :update


    get "/timeslots", TimeslotController, :index

    get "/programs/:program_id/images/:id/edit", ImageController, :edit
    get "/programs/:program_id/images/new", ImageController, :new
    post "/programs/:program_id/images/", ImageController, :create
    patch "/programs/:program_id/images/:id", ImageController, :update
    put "/programs/:program_id/images/:id", ImageController, :update
    delete "/programs/:program_id/images/:id", ImageController, :delete

    get "/images", ImageController, :index
  end

  scope "/", RadioappWeb do
    pipe_through [:browser, :require_authenticated_user, :user, :tenant_in_session]

    live "/users/invite", UserInvitationLive, :new

    live "/programs/:program_id/logs/", LogLive.Index, :index
    live "/programs/:program_id/logs/new", LogLive.Index, :new
    live "/programs/:program_id/logs/:id/edit", LogLive.Index, :edit

    live "/programs/:program_id/logs/:id", LogLive.Show, :show
    live "/programs/:program_id/logs/:id/show/edit", LogLive.Show, :edit

    live "/programs/:program_id/logs/:log_id/segments", SegmentLive.Index, :index
    live "/programs/:program_id/logs/:log_id/segments/new", SegmentLive.Index, :new
    live "/programs/:program_id/logs/:log_id/segments/:id/edit", SegmentLive.Index, :edit
    live "/programs/:program_id/logs/:log_id/segments/upload_instructions", SegmentLive.Index, :upload_instructions

    live "/programs/:program_id/logs/:log_id/segments/:id", SegmentLive.Show, :show
    live "/programs/:program_id/logs/:log_id/segments/:id/show/edit", SegmentLive.Show, :edit

    get "/admin", PageController, :admin

    # Add PlayoutSegment resources
    live "/playout_segments", PlayoutSegmentLive.Index, :index
    live "/playout_segments/:id/edit", PlayoutSegmentLive.Index, :edit

  end


  scope "/", RadioappWeb do
    pipe_through [:browser, :require_authenticated_user, :admin, :tenant_in_session]
      live "/admin/links", LinkLive.Index, :index
      live "/admin/links/new", LinkLive.Index, :new
      live "/admin/links/:id/edit", LinkLive.Index, :edit

      live "/admin/links/:id", LinkLive.Show, :show
      live "/admin/links/:id/show/edit", LinkLive.Show, :edit

      live "/admin/categories", CategoryLive.Index, :index
      live "/admin/categories/new", CategoryLive.Index, :new
      live "/admin/categories/:id/edit", CategoryLive.Index, :edit

      live "/admin/categories/:id", CategoryLive.Show, :show
      live "/admin/categories/:id/show/edit", CategoryLive.Show, :edit

      get "/admin/logs", LogController, :index
      post "/admin/logs/search", LogController, :search
      post "/admin/logs/export", LogController, :export

  end

  scope "/", RadioappWeb do
    pipe_through [:browser, :require_authenticated_user, :api_admin, :tenant_in_session]
      live "/admin/apikey", ApikeyLive.Index, :index
      live "/admin/apikey/new", ApikeyLive.Index, :new

  end



  scope "/", RadioappWeb do
    pipe_through [:browser, :require_authenticated_user, :admin]

    delete "/programs/:id", ProgramController, :delete

    delete "/users/:id", UserController, :delete

    get "/programs/:program_id/timeslots/:id/edit", TimeslotController, :edit
    get "/programs/:program_id/timeslots/new", TimeslotController, :new
    post "/programs/:program_id/timeslots/", TimeslotController, :create
    patch "/programs/:program_id/timeslots/:id", TimeslotController, :update
    put "/programs/:program_id/timeslots/:id", TimeslotController, :update
    delete "/programs/:program_id/timeslots/:id", TimeslotController, :delete

    resources "/stationdefaults", StationdefaultsController

  end

  scope "/", RadioappWeb do
    pipe_through [:browser, :tenant_in_session]
    get "/feed", FeedController, :index

    # Route for pop-out player
    live "/player", PlayerLive, :pop, container: {:main, class: "px-20 sm:px-6 lg:px-8 popup-container"}

  end

  scope "/", RadioappWeb do
    pipe_through :browser

    get "/",TimeslotController, :index_by_day

    get "/schedule/:id",TimeslotController, :index_by_day

    get "/programs", ProgramController, :index
    get "/programs/:id", ProgramController, :show

    get "/programs/:program_id/images/:id", ImageController, :show

    get "/archives", PageController, :archives
    get "/podcasts", PageController, :podcasts



 end

end
