-module(tcp_rex).

%% API exports
-export([start_server/1, start_server/2]).
-export([connect/2, connect/3, call/4, call/5, close/1]).

%%====================================================================
%% API functions
%%====================================================================


start_server(Port) ->
    start_server(Port, erlang:get_cookie()).

start_server(_Port, nocookie) ->
    exit(tcp_rex_nocookie);

start_server(Port, Cookie) ->
    tcp_rex_protocol:start(Port, Cookie).

connect(Address, Port) ->
    connect(Address, Port, erlang:get_cookie()).

connect(Address, Port, Cookie) ->
    case gen_tcp:connect(Address, Port, [binary, {packet, 4}, {active, false}]) of
        {ok, Socket} ->
            {ok, {Socket, Cookie}};
        Error ->
            Error
    end.

call(Socket, M, F, A) ->
    call(Socket, M, F, A, 5000).

call({Socket, Cookie}, M, F, A, Timeout) ->
    send(Socket, {call, {M, F, A}, Cookie}, Timeout).

close(Socket) ->
    ok = gen_tcp:close(Socket).

%%====================================================================
%% Internal functions
%%====================================================================

send(Socket, Term, Timeout) ->
    gen_tcp:send(Socket, term_to_binary(Term)),
    case gen_tcp:recv(Socket, 0, Timeout) of
        {ok, Binary} ->
            binary_to_term(Binary);
        {error, Reason} ->
            {badrpc, Reason}
    end.
