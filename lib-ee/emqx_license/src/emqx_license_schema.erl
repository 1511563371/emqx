%%--------------------------------------------------------------------
%% Copyright (c) 2022 EMQ Technologies Co., Ltd. All Rights Reserved.
%%--------------------------------------------------------------------

-module(emqx_license_schema).

-include_lib("typerefl/include/types.hrl").

%%------------------------------------------------------------------------------
%% hocon_schema callbacks
%%------------------------------------------------------------------------------

-behaviour(hocon_schema).

-export([roots/0, fields/1, validations/0]).

roots() -> [{license,
               hoconsc:mk(hoconsc:union([hoconsc:ref(?MODULE, key_license),
                   hoconsc:ref(?MODULE, file_license)]),
                   #{desc => "TODO"})}
           ].

fields(key_license) ->
    [ {key, #{type => string(),
              sensitive => true, %% so it's not logged
              desc => "Configure the license as a string"
             }}
    | common_fields()];
fields(file_license) ->
    [ {file, #{type => string(),
               desc => "Path to the license file"
              }}
    | common_fields()].

common_fields() ->
    [
        {connection_low_watermark, #{type => emqx_schema:percent(),
            default => "75%", desc => ""
        }},
        {connection_high_watermark, #{type => emqx_schema:percent(),
            default => "80%", desc => ""
        }}
    ].

validations() ->
    [ {check_license_watermark, fun check_license_watermark/1}].

check_license_watermark(Conf) ->
    case hocon_maps:get("license.connection_low_watermark", Conf) of
        undefined -> true;
        Low ->
            High = hocon_maps:get("license.connection_high_watermark", Conf),
            case High =/= undefined andalso High > Low of
                true -> true;
                false -> {bad_license_watermark, #{high => High, low => Low}}
            end
    end.
