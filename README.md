# Logz

# Single log class to rule them all.

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

logger = Logz.new

You can use this logger just as regular Logger class in Ruby:

logger.debug 'Foo'
logger.info 'Bar'
logger.warn 'Warning'
logger.error 'Error'
```

## Adding another logger

```
logger.add 'alerts'
# or:
logger << 'alerts'
```

This new logger will be created in the default folder, with same name (alerts.log)


### Adding multiple loggers

```
logger.add ['alerts', 'messages']
logger.alerts.warn "Foo"
logger.messages.info "Bar"
# or
logger[:messages].info "Foobar"
```

### Setting up file's path

Setting global log file directory:
```
logger = Logz.new('/tmp/log')
```

Selected file path:
```
logger.add 'alerts', '/var/log/alerts/'
```

### Adding dual logger

Dual logger allows you to write in log file and STDOUT in the same time.

```
logger.add 'alerts', to_stdout: true
logger.info 'foobar' # outputs to STDOUT and alerts.log
```

### Extra tips:

Setting up custom formatter for all logs:
```
logger.each do |l|
  l.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
  end
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vizakenjack/logz. This project is intended to be a safe, welcoming space for collaboration.
