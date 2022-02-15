%%--------------------------------------------------------------------
%% Copyright (c) 2017-2022 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_exhook_schema).

-dialyzer(no_return).
-dialyzer(no_match).
-dialyzer(no_contracts).
-dialyzer(no_unused).
-dialyzer(no_fail_call).

-include_lib("typerefl/include/types.hrl").

-behaviour(hocon_schema).

-type duration() :: integer().

-typerefl_from_string({duration/0, emqx_schema, to_duration}).

-reflect_type([duration/0]).

-export([namespace/0, roots/0, fields/1, server_config/0]).

namespace() -> exhook.

roots() -> [exhook].

fields(exhook) ->
    [{servers,
      sc(hoconsc:array(ref(server)),
          #{default => []})}
    ];

fields(server) ->
    [ {name, sc(binary(), #{})}
    , {enable, sc(boolean(), #{default => true})}
    , {url, sc(binary(), #{})}
    , {request_timeout,
       sc(duration(), #{default => "5s"})}
    , {failed_action, failed_action()}
    , {ssl,
       sc(ref(ssl_conf), #{})}
    , {auto_reconnect,
       sc(hoconsc:union([false, duration()]),
          #{default => "60s"})}
    , {pool_size,
       sc(integer(), #{default => 8, example => 8})}
    ];

fields(ssl_conf) ->
    Schema = emqx_schema:client_ssl_opts_schema(#{}),
    lists:keydelete(user_lookup_fun, 1, Schema).

%% types
sc(Type, Meta) -> Meta#{type => Type}.

ref(Field) ->
    hoconsc:ref(?MODULE, Field).

failed_action() ->
    sc(hoconsc:enum([deny, ignore]),
       #{default => deny}).

server_config() ->
    fields(server).
