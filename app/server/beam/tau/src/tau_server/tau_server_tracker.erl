%% Tracker process for a timer group - keeps a map of timer refs and
%% corresponding absolute times
%% --
%% This file is part of Sonic Pi: http://sonic-pi.net
%% Full project source: https://github.com/samaaron/sonic-pi
%% License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
%% ++

-module(tau_server_tracker).

%% API
-export([start_link/1, track/3, forget/2, flush/2]).

%% internal
-export([loop/2]).

%% API

start_link(Tag) ->
    spawn_link(fun() -> init(Tag) end).

track(Timer, Time, Tracker) ->
    Tracker ! {track, Timer, Time}.

forget(Timer, Tracker) ->
    Tracker ! {forget, Timer}.

flush(Which, Tracker) ->
    Tracker ! {flush, Which}.


%% server loop

init(Tag) ->
    loop(Tag, #{}).

loop(Tag, Map) ->
    receive
        {track, Ref, Time} ->
            logger:debug("track timer ~p for time ~f", [Ref, Time]),
            Map1 = Map#{Ref => Time},
            ?MODULE:loop(Tag, Map1);
        {forget, Ref} ->
            logger:debug("forget timer ~p for time ~f",
                  [Ref, maps:get(Ref, Map)]),
            Map1 = maps:remove(Ref, Map),
            ?MODULE:loop(Tag, Map1);
        {flush, all} ->
            logger:debug("forget all timers tagged \"~s\" ", [Tag]),
            lists:foreach(fun cancel_timer/1,
                          maps:keys(Map)),
            ?MODULE:loop(Tag, #{});
        {flush, Time} ->
            %% flush all timers to trigger later than a specified time
            logger:debug("forget timers tagged \"~s\" later than ~p " ,
                  [Tag, Time]),
            Map1 = lists:foldl(
                     fun (R, M) ->
                             T = maps:get(R, M),
                             if T > Time ->
                                     cancel_timer(R),
                                     maps:remove(R, M);
                                true ->
                                     M
                             end
                     end,
                     maps:keys(Map),
                     Map),
            ?MODULE:loop(Tag, Map1)
    end.

cancel_timer(Ref) ->
    %% cancel a timer without waiting and without checking the result
    erlang:cancel_timer(Ref, [{async, true},{info,false}]),
    ok.
