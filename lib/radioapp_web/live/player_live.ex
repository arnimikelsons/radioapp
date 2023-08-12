defmodule RadioappWeb.PlayerLive do
  use RadioappWeb, :live_player_view
  alias Radioapp.Station

  def mount(_params, _session, socket) do

    if connected?(socket) do
      Process.send_after(self(), :tick, 60 * 1000) # In 1 minute
    end

    socket =
      socket
      |> assign(
        volume: 1.0,
        saved: 1.0,
        playing: false
      )

      socket = assign_show(socket)

    if socket.assigns.live_action == :pop do
      socket = assign(socket, page_title: "Pop-Up Player")
      socket = assign(socket, layout: {RadioappWeb.Layouts, "live_player"})
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_event("play_pause", _, socket) do
    %{playing: playing} = socket.assigns

    cond do
      playing ->
        {:noreply, assign(socket, playing: false)}

      !playing ->
        {:noreply, assign(socket, playing: true)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_info(:tick, socket) do
    socket = assign_show(socket)
    {:noreply, socket}
  end

  defp assign_show(socket) do
    now = DateTime.to_naive(Timex.now("America/Toronto"))
    time_now = DateTime.to_time(Timex.now("America/Toronto"))
    weekday = Timex.weekday(now)

    showName = Station.get_program_from_time(weekday, time_now)
    startTime = Station.get_program_now_start_time(weekday, time_now)

    assign(socket,
      show_name: showName,
      show_start: startTime
    )
  end

  # defp js_play_pause() do
  #   JS.push("play_pause")
  #   # |> JS.dispatch("js:play_pause", to: "#audio-player")
  # end

  def render(assigns) do
    ~H"""
     <div class="flex-grow-1 order-5 md:order-none audio-container">
           <div id="audio-player" class="audio-player" role="region" aria-label="Player">
            <div id="audio-ignore">
              <audio id="music" crossorigin="anonymous" preload="auto">
                <source src="https://audio.cfrc.ca/stream" type="audio/mpeg" />
              </audio>
            </div>
            <div class="first-row row">
              <!-- play/pause -->
              <button
                tabindex="0"
                type="button"
                id="pButton"
                class="play-button"
                aria-label="Play">
                  <svg
                    id="player-play"
                    width="70"
                    height="70"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke="currentColor"
                      fill="currentColor"
                      transform="rotate(90 12.8947 12.3097)"
                      id="svg_6"
                      d="m9.40275,15.10014l3.49194,-5.58088l3.49197,5.58088l-6.98391,0z"
                      stroke-width="1.5"
                      fill="none"
                    />
                  </svg>
                  <div class="pause-container" id="player-pause">
                    <svg
                      class="player-pause"
                      xmlns="http://www.w3.org/2000/svg"

                      fill="currentColor"
                      class="bi bi-pause-fill"
                      viewBox="1 1 14 14">
                      <path
                        stroke-width="1.5"
                        d="M5.5 3.5A1.5 1.5 0 0 1 7 5v6a1.5 1.5 0 0 1-3 0V5a1.5 1.5 0 0 1 1.5-1.5zm5 0A1.5 1.5 0 0 1 12 5v6a1.5 1.5 0 0 1-3 0V5a1.5 1.5 0 0 1 1.5-1.5z"/>
                    </svg>
                  </div>
              </button>
              <!-- /play/pause -->
            </div>
            <div class="second-row row">
              <button id="muteControl" aria-label="mute" class="volumeControl volumeLabel player-button" for="volume">
                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-volume-up-fill" viewBox="0 0 16 16">
                    <path d="M11.536 14.01A8.473 8.473 0 0 0 14.026 8a8.473 8.473 0 0 0-2.49-6.01l-.708.707A7.476 7.476 0 0 1 13.025 8c0 2.071-.84 3.946-2.197 5.303l.708.707z"/>
                    <path d="M10.121 12.596A6.48 6.48 0 0 0 12.025 8a6.48 6.48 0 0 0-1.904-4.596l-.707.707A5.483 5.483 0 0 1 11.025 8a5.483 5.483 0 0 1-1.61 3.89l.706.706z"/>
                    <path d="M8.707 11.182A4.486 4.486 0 0 0 10.025 8a4.486 4.486 0 0 0-1.318-3.182L8 5.525A3.489 3.489 0 0 1 9.025 8 3.49 3.49 0 0 1 8 10.475l.707.707zM6.717 3.55A.5.5 0 0 1 7 4v8a.5.5 0 0 1-.812.39L3.825 10.5H1.5A.5.5 0 0 1 1 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06z"/>
                  </svg>
              </button>
              <input
                aria-label="volume"
                class="win10-thumb"
                type="range"
                name="volume"
                id="volume"
                min="0.0"
                max="1.0"
                step="0.1"
                value="1.0"
              />
            </div>
            <div class="third-row row">
              <div>
                <h3>Now Playing</h3>
                <h2 class="text-xl font-medium text-black pop-up-title"><%= @show_name %></h2>
                <h3 id="time-format"><%= @show_start %></h3>
              </div>
            </div>
          </div>
        </div>
    """
    # ~H"""
    # <div id="audio-player" phx-hook="AudioPlayer" class="w-full" role="region" aria-label="Player">
    #   <div id="audio-ignore" phx-update="ignore">
    #     <audio id='music' crossorigin='anonymous'></audio>

    #   </div>
    #   <div class="first-row row testing">
    #     <button
    #       type="button"
    #       id="play-pause-button"
    #       class="mx-auto"
    #       phx-click={js_play_pause()}
    #       aria-label={
    #         if @playing do
    #           "Pause"
    #         else
    #           "Play"
    #         end
    #       }
    #     >
    #       <%= if @playing do %>
    #         <svg id='player-pause' width="50" height="50" fill="none">
    #           <circle
    #             class="text-black dark:text-gray-500"
    #             cx="25"
    #             cy="25"
    #             r="24"
    #             stroke="currentColor"`
    #             stroke-width="1.5"
    #           />
    #           <path d="M18 16h4v18h-4V16zM28 16h4v18h-4z" fill="currentColor" />
    #         </svg>
    #       <% else %>
    #         <svg
    #           id="player-play"
    #           width="50"
    #           height="50"
    #           xmlns="http://www.w3.org/2000/svg"
    #           fill="none"
    #           viewBox="0 0 24 24"
    #           stroke="currentColor"
    #         >
    #           <circle
    #             id="svg_1"
    #             stroke-width="0.8"
    #             stroke="currentColor"
    #             r="11.4"
    #             cy="12"
    #             cx="12"
    #             class="text-black dark:text-gray-500"
    #           />
    #           <path
    #             stroke="null"
    #             fill="currentColor"
    #             transform="rotate(90 12.8947 12.3097)"
    #             id="svg_6"
    #             d="m9.40275,15.10014l3.49194,-5.58088l3.49197,5.58088l-6.98391,0z"
    #             stroke-width="1.5"
    #             fill="none"
    #           />
    #         </svg>
    #       <% end %>
    #     </button>
    #     <%= if @live_action != :pop do %>
    #       <div class="pop-container" id="pop-container">
    #         <a href='./player'
    #           onclick="window.open(this.href,'targetWindow',
    #             `toolbar=no,
    #               location=no,
    #               status=no,
    #               menubar=no,
    #               scrollbars=yes,
    #               resizable=yes,
    #               width=550,
    #               height=300`);
    #             return false;"
    #         >
    #           <span id="player-pop-up" class="player-button">
    #             <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-box-arrow-up-right" viewBox="0 0 16 16">
    #               <path fill-rule="evenodd" d="M8.636 3.5a.5.5 0 0 0-.5-.5H1.5A1.5 1.5 0 0 0 0 4.5v10A1.5 1.5 0 0 0 1.5 16h10a1.5 1.5 0 0 0 1.5-1.5V7.864a.5.5 0 0 0-1 0V14.5a.5.5 0 0 1-.5.5h-10a.5.5 0 0 1-.5-.5v-10a.5.5 0 0 1 .5-.5h6.636a.5.5 0 0 0 .5-.5z"/>
    #               <path fill-rule="evenodd" d="M16 .5a.5.5 0 0 0-.5-.5h-5a.5.5 0 0 0 0 1h3.793L6.146 9.146a.5.5 0 1 0 .708.708L15 1.707V5.5a.5.5 0 0 0 1 0v-5z"/>
    #             </svg>
    #           </span>
    #         </a>
    #       </div>
    #     <% end %>
    #   </div>

    #   <div class="second-row row">
    #     <!-- <span id="current-time" class="time">0:00</span>
    #     <input type="range" id="seek-slider" max="100" value="0">
    #     <span id="duration" class="time">0:00</span> -->
    #     <label id="muteControl" class="volumeControl volumeLabel player-button" for="volume">
    #       <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-volume-up-fill" viewBox="0 0 16 16">
    #           <path d="M11.536 14.01A8.473 8.473 0 0 0 14.026 8a8.473 8.473 0 0 0-2.49-6.01l-.708.707A7.476 7.476 0 0 1 13.025 8c0 2.071-.84 3.946-2.197 5.303l.708.707z"/>
    #           <path d="M10.121 12.596A6.48 6.48 0 0 0 12.025 8a6.48 6.48 0 0 0-1.904-4.596l-.707.707A5.483 5.483 0 0 1 11.025 8a5.483 5.483 0 0 1-1.61 3.89l.706.706z"/>
    #           <path d="M8.707 11.182A4.486 4.486 0 0 0 10.025 8a4.486 4.486 0 0 0-1.318-3.182L8 5.525A3.489 3.489 0 0 1 9.025 8 3.49 3.49 0 0 1 8 10.475l.707.707zM6.717 3.55A.5.5 0 0 1 7 4v8a.5.5 0 0 1-.812.39L3.825 10.5H1.5A.5.5 0 0 1 1 10V6a.5.5 0 0 1 .5-.5h2.325l2.363-1.89a.5.5 0 0 1 .529-.06z"/>
    #         </svg>
    #     </label>
    #     <input
    #       class="win10-thumb"
    #       type="range"
    #       name="volume"
    #       id="volume"
    #       min="0.0"
    #       max="1.0"
    #       step="0.1"
    #       value="1.0"
    #     />
    #   </div>
    #   <div class="third-row row">
    #     <div>
    #       <h3>Now Playing</h3>
    #       <h2 class="text-xl font-medium text-black pop-up-title"><%= @show_name %></h2>
    #       <h3 id="time-format"><%= @show_start %></h3>
    #     </div>
    #   </div>
    # </div>
    # """
  end
end
