{application, tsung_recorder,
      [{description,  "tsung recorder"},
       {vsn,          "1.7.1_dev"},
       {modules,      [
					   tsung_recorder,
					   ts_recorder_sup,
					   ts_client_proxy_sup,
					   ts_proxy_recorder,
					   ts_proxy_listener
					  ]},
       {registered,   [
                       ts_proxy_recorder,
                       ts_proxy_listener
					  ]},
	   {env,		[
					 {debug_level, 6},
					 {ts_cookie, "humhum"},
					 {log_file, "./tsung.log"},
					 {plugin, ts_proxy_http},
                     {parent_proxy, false},
					 {pgsql_server, "127.0.0.1"},
					 {pgsql_port, 5432},
					 {proxy_log_file, "./tsung_recorder"},
					 {proxy_listen_port, 8090}
					]},
	   {applications, [kernel,stdlib,asn1,crypto,public_key,ssl,crypto]},
       {mod,          {tsung_recorder, []}}
	  ]}.