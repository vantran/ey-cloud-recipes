#
# Cookbook Name:: sidekiq
# Attrbutes:: default
#

default[:sidekiq] = {
  # Sidekiq will be installed on to application/solo instances,
  # unless a utility name is set, in which case, Sidekiq will
  # only be installed on to a utility instance that matches
  # the name
  :utility_name => 'utility',
  
  # Number of workers (not threads)
  :workers => 3,
  
  # Concurrency
  :concurrency => 25,
  
  # Queues
  :queues => {
    # :queue_name => priority
    :default => 1,
    :mailers => 1,
    :searchkick => 1
  },
  
  # Verbose
  :verbose => false
}
