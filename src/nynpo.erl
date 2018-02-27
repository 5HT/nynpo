-module(nynpo).
-behaviour(application).
-compile(export_all).
-export([start/2, stop/1, init/1]).
-include_lib("n2o/include/wf.hrl").
-include("telegram.hrl").

main(A) -> mad:main(A).

log_level()   -> info.
log_modules() -> [nynpo].

init([])    -> {ok, {{one_for_one, 5, 10}, [] }}.
start(_, _) -> X = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
        n2o_async:start(#handler{module=?MODULE,class=caching,group=n2o,state=[],name="NYNPO"}),
               X.
stop(_)     -> ok.

proc(init,#handler{}=Async) ->
    wf:info(?MODULE,"NYNJA BOT Init: ~p~n",[init]),
    application:start(asn1),
    application:start(public_key),
    application:start(ssl),
    Timer = timer_restart(ping()),
    {ok,Async#handler{state=Timer}};

proc({timer,ping},#handler{state=Timer}=Async) ->
    case Timer of undefined -> skip; _ -> erlang:cancel_timer(Timer) end,
    wf:info(?MODULE,"NYNJA BOT TICK: ~p~n",[ping]),
    Rooms = application:get_env(nynpo,rooms,["CanYaCommunity"]),
    [ process_room(R) || R <- Rooms],
    {reply,ok,Async#handler{state=timer_restart(ping())}}.

process_room(Room) ->
    APIKEY = application:get_env(nynpo,bot,"548231922:AAHmXMMr38XGtH0tJMDUdiByheT2mZ7qkVI"),
    End = "https://api.telegram.org/bot",
    {_,{_,_,Res}} = httpc:request(get, {End++APIKEY++"/getChat?chat_id=@"++Room, []}, [], []),
    {{D,M,Y},{H,Min,S}} = {date(),time()},
    #{<<"result">> := #{<<"id">> := Id_}} = jsone:decode(list_to_binary(Res)),
    Id = io_lib:format("~p",[Id_]),
    {_,{_,_,Res2}} = httpc:request(get, {End++APIKEY++"/getChatMembersCount?chat_id="++Id, []}, [], []),
    #{<<"result">> := Count} = jsone:decode(list_to_binary(Res2)),
    Time = io_lib:format("~w/~w/~w, ~w:~w:~w",[D,M,Y,H,Min,S]),
    Print = io_lib:format("~s, ~p, ~s, ~p~n",[Time,Room,Id,Count]),
    io:format(Print),
    file:write_file(Room, list_to_binary(Print), [write,append]),
    ok.

timer_restart(Diff) -> {X,Y,Z} = Diff, erlang:send_after(1000*(Z+60*Y+60*60*X),self(),{timer,ping}).
ping() -> application:get_env(nynpo,timer,{0,0,5}).
