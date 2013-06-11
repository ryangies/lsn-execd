lsn-execd
=========

Execution daemon which runs commands without arguments and are referred to by a 
shared secret key

<pre>
Perl script (the client)                  Running execd service (as root)
------------------------                  -------------------------------
Makes an HTTP GET request
passing one parameter,
the secret key.           »–––––––––––––› If the secret key checks out,
                                          execute the associated command.

                                          Return the command output as
Inspect response          ‹–––––––––––––« the GET response.
</pre>

The result of an installation:

<pre>
/etc/execd
├── conf
│   ├── commands.hf             Commands which are allowed to run
│   └── execd.hf                Server configuration (port, access control, etc)
├── lib
│   └── Net
│       └── Execd
│           ├── Client.pm       Connecting clients use this library
│           ├── Command.pm
│           └── Server.pm
└── scripts
    ├── execd                   Daemon
    ├── execd-client-test       Executes the known 'Okay' command
    ├── execd-genkey            Generates a new secret key
    └── execd-rc                SysVinit service script
</pre>

Service usage:

<pre>
# /etc/init.d/execd 
Usage: execd {start|stop|restart|reload|status}
</pre>

Other files:

<pre>
/var/log/execd.log
/var/run/execd.pid
</pre>
