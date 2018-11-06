-module(tcp_rex).

%% API exports
-export([start_server/1]).
-export([connect/2, call/4, call/5, close/1]).

%%====================================================================
%% API functions
%%====================================================================

start_server(Port) ->
    Ref = make_ref(),
    {ok, _} = ranch:start_listener(Ref,
                                   ranch_tcp,
                                   #{
                                     num_acceptors => 1,
                                     max_connections => infinity,
                                     socket_opts => [{port, Port}]
                                    },
                                   tcp_rex_protocol, []
                                  ).

connect(Address, Port) ->
    gen_tcp:connect(Address, Port, [binary, {packet, 4}, {active, false}]).

call(Socket, M, F, A) ->
    call(Socket, M, F, A, 5000).

call(Socket, M, F, A, Timeout) ->
    send(Socket, {call, {M, F, A}}, Timeout).

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
