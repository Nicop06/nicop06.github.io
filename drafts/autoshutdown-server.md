## Auto shutdown script

Here is a script I wrote to automatically shut down your server when it isn't
used. You can access this script directly on my [GitHub repository][github].

It can run in a crontab or as a daemon, regularly testing if the server is
in use. After a configurable amount of time without any activity, it will
shut down the system. You can create a configuration file to override some
settings. The tests include checking for connected users and established
network connections. I encourage you to read the code and modify the
script, and don't hesitate to send feedback.

