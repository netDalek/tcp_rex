-module(tcp_rex_protocol).
-behaviour(ranch_protocol).

-export([start_link/4]).
-export([init/3]).

start_link(Ref, _Socket, Transport, Opts) ->
    Pid = spawn_link(?MODULE, init, [Ref, Transport, Opts]),
    {ok, Pid}.

init(Ref, Transport, _Opts = []) ->
    {ok, Socket} = ranch:handshake(Ref),
    Transport:setopts(Socket, [{packet, 4}, {packet_size, 10*1024*1024}]),
    loop(Socket, Transport).

loop(Socket, Transport) ->
    case Transport:recv(Socket, 0, infinity) of
        {ok, Data} ->
            case binary_to_term(Data) of
                {call, {M, F, A}} ->
                    Res = apply(M, F, A),
                    gen_tcp:send(Socket, term_to_binary(Res)),
                    loop(Socket, Transport);
                Other ->
                    gen_tcp:send(Socket, term_to_binary({unknown_message, Other}))
            end;
        _ ->
            ok = Transport:close(Socket)
    end.
