# Logz

## Key features:
- Manage all your log files
- Easy and lightweight, no other gems required
- Write in two streams: STDOUT and log file when you need it
- Set level of all logs just in single method
- Add and remove 


## Installation

Add this line to your application's Gemfile:

```
gem 'logz'
```

And then execute:

    $ bundle

Or install using rubygems:

    $ gem install logz

### Basic usage

```
require 'logz'

logz = Logz.new

You can use this logger just as regular Logger class in Ruby:

# outputs to STDOUT
logz.debug 'Foo'
logz.info 'Bar'
logz.warn 'Warning'
logz.error 'Error'
```

## Add logger

```
logz.add 'server'
# same as:
logz.add 'server', 'log/server', to_stdout: true, to_file: true
```

This new logger will be created in the default folder, with the same name (server.log). By default, it writes both to STDOUT and log file.


## Select STDOUT or file logger

```
logz.add 'client', to_stdout: true, to_file: false
logz.client.info 'test client' # writes to STDOUT only
```

```
logz.add 'server', to_stdout: false, to_file: true
logz.server.info 'test server' # writes to log file only
```


### Add multiple loggers

```
logz.add ['server', 'client']
logz.server.warn "Foo"
logz.client.info "Bar"
# or
logz[:server].warn "Foo"
logz[:client].info "Bar"
```

### Iterate as using array

```
logz.each do |logger|
  logger.level = Logger::WARN
end
```

Or do the same:
```
logz.global_level = Logger::WARN
```

### Configuration

Config file is optional. Default params:

```
Logz.configuration do |config|
  # Set loggers in config
  config.loggers = [] # example: %w(server client important)

  # Write to STDOUT by default (may be disabled on production)
  config.output_to_stdout = true

  # Write to log file by default (may be disabled on development)
  config.output_to_file = true

  # Log file default extension
  config.extension = 'log'

  # Default folder is ./log. You may also specify absolute path: '/var/log'
  config.folder = 'log'

  # Suffix for log filename
  config.suffix = ''

  # Prefix for log filename
  config.prefix = ''
end
```

### Extra tips:

Set up custom formatter for all logs:
```
logger.each do |l|
  l.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vizakenjack/logz. This project is intended to be a safe, welcoming space for collaboration.
