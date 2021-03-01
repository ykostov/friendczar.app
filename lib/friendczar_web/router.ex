defmodule FriendczarWeb.Router do
  use FriendczarWeb, :router

  import FriendczarWeb.PersonAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_person
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FriendczarWeb do
    pipe_through :browser

    get "/", RoomController, :index

    # Rooms
    # resources("/rooms", RoomController)
    get "/rooms/new", RoomController, :new
    post "/rooms", RoomController, :create
    get "/rooms/:id", RoomController, :show
    get "/rooms/:id/edit", RoomController, :edit
    put "/rooms/:id", RoomController, :update
    delete "/room/:id", RoomController, :delete

    # Users
    resources("/sessions", SessionController, only: [:new, :create])
    resources("/registration", RegistrationController, only: [:new, :create]) 
    delete "/sign_out", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", FriendczarWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FriendczarWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", FriendczarWeb do
    pipe_through [:browser, :redirect_if_person_is_authenticated]

    get "/persons/register", PersonRegistrationController, :new
    post "/persons/register", PersonRegistrationController, :create
    get "/persons/log_in", PersonSessionController, :new
    post "/persons/log_in", PersonSessionController, :create
    get "/persons/reset_password", PersonResetPasswordController, :new
    post "/persons/reset_password", PersonResetPasswordController, :create
    get "/persons/reset_password/:token", PersonResetPasswordController, :edit
    put "/persons/reset_password/:token", PersonResetPasswordController, :update
  end

  scope "/", FriendczarWeb do
    pipe_through [:browser, :require_authenticated_person]

    get "/persons/settings", PersonSettingsController, :edit
    put "/persons/settings", PersonSettingsController, :update
    get "/persons/settings/confirm_email/:token", PersonSettingsController, :confirm_email
  end

  scope "/", FriendczarWeb do
    pipe_through [:browser]

    delete "/persons/log_out", PersonSessionController, :delete
    get "/persons/confirm", PersonConfirmationController, :new
    post "/persons/confirm", PersonConfirmationController, :create
    get "/persons/confirm/:token", PersonConfirmationController, :confirm
  end
end
