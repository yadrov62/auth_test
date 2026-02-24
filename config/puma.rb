# Puma configuration for the application
# Default port is 4000 (not 3000)

# Puma can serve each request in a thread from an internal thread pool.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests (default: 4000)
port ENV.fetch("PORT", 4000)

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV", "development")

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

