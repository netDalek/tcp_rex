tcp_rex
=====

Then simpliest tcp rpc with erlang

Build
-----

    $ rebar3 compile

Sample
-----

```
> rebar3 shell --sname dd
Erlang/OTP 21 [erts-10.0.5] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Eshell V10.0.5  (abort with ^G)
(dd@a2p-dev)1> application:ensure_all_started(tcp_rex).
{ok,[ranch,tcp_rex]}
(dd@a2p-dev)2> tcp_rex:start_server(2222).
{ok,<0.162.0>}
```

```
> rebar3 shell --sname aa
Erlang/OTP 21 [erts-10.0.5] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Eshell V10.0.5  (abort with ^G)
(aa@a2p-dev)19> {ok, S} = tcp_rex:connect("127.0.0.1", 2222).
{ok,{#Port<0.22>,'BXVCTIPIVZWYKLFZCRUY'}}
(aa@a2p-dev)20> tcp_rex:call(S, erlang, node, []).
'dd@a2p-dev'
```
