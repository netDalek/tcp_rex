-module(tcp_rex_protocol).
-behaviour(ranch_protocol).

-export([start/2]).
-export([start_link/4]).
-export([init/3]).

start(Port, Cookie) ->
    Ref = make_ref(),
    {ok, _} = ranch:start_listener(Ref,
                                   ranch_tcp,
                                   #{
                                     num_acceptors => 1,
                                     max_connections => infinity,
                                     socket_opts => [{port, Port}]
                                    },
                                   tcp_rex_protocol, [Cookie]
                                  ).

start_link(Ref, _Socket, Transport, Opts) ->
    Pid = spawn_link(?MODULE, init, [Ref, Transport, Opts]),
    {ok, Pid}.

init(Ref, Transport, [Cookie]) ->
    {ok, Socket} = ranch:handshake(Ref),
    Transport:setopts(Socket, [{packet, 4}, {packet_size, 10*1024*1024}]),
    loop(Socket, Transport, Cookie).

loop(Socket, Transport, Cookie) ->
    case Transport:recv(Socket, 0, infinity) of
        {ok, Data} ->
            case binary_to_term(Data) of
                {call, {M, F, A}, Cookie} ->
                    Res = apply(M, F, A),
                    gen_tcp:send(Socket, term_to_binary(Res));
                {call, _MFA, _} ->
                    timer:sleep(3000),
                    gen_tcp:send(Socket, term_to_binary({badrpc, wrong_cookie}));
                _Other ->
                    gen_tcp:send(Socket, term_to_binary({badrpc, unknown_message}))
            end,
            loop(Socket, Transport, Cookie);
        _ ->
            ok = Transport:close(Socket)
    end.
