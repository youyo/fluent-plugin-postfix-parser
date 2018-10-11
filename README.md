# fluent-plugin-postfix-parser

This is [fluentd](https://fluentd.org/) filter plugin.  
Parse postfix logs, multi lines become a one line log.

## Installation

### RubyGems

```
$ gem install fluent-plugin-postfix-parser
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-postfix-parser"
```

And then execute:

```
$ bundle
```

## Usage

### Configuration

```
<source>
  @type forward
</source>

<filter postfix.log>
  @type postfix_parser
  # key (string) (optional) Default value: `message`.
  key message
</filter>

<match **.**>
  @type stdout
</match>
```

### Input

```
$ echo '{"message":"Oct 10 15:59:28 mail postfix/smtpd[1830]: C6E0DDB74006: client=example.com[127.0.0.1]"}' | fluent-cat postfix.log
$ echo '{"message":"Oct 10 15:59:28 mail postfix/cleanup[1894]: C6E0DDB74006: message-id=<A40CF64D-7F2D-42E4-8A76-CBFFF64A6EB1@example.com>"}' | fluent-cat postfix.log
$ echo '{"message":"Oct 10 15:59:28 mail postfix/qmgr[18719]: C6E0DDB74006: from=<test@example.com>, size=309891, nrcpt=1 (queue active)"}' | fluent-cat postfix.log
$ echo '{"message":"Oct 10 15:59:32 mail postfix/smtp[1874]: C6E0DDB74006: to=<test@example.ddd>, relay=example.ddd[192.168.0.30]:25, delay=3.4, delays=0.11/0/0.38/2.9, dsn=2.0.0, status=sent (250 2.0.0 OK 1539154772 az9-v6si5976496plb.190 - gsmtp)"}' | fluent-cat postfix.log
$ echo '{"message":"Oct 10 15:59:32 mail postfix/qmgr[18719]: C6E0DDB74006: removed"}' | fluent-cat postfix.log
```

### Output

```
2018-10-11 02:03:25.369299000 +0900 postfix.log: {"time":"Oct 10 15:59:28","hostname":"mail","process":"postfix/smtpd[1830]","queue_id":"C6E0DDB74006","client_hostname":"example.com","client_ip":"127.0.0.1","messages":[{"time":"Oct 10 15:59:32","to":"test@example.ddd","relay_hostname":"example.ddd","relay_ip":"192.168.0.30","relay_port":"25","delay":"3.4","delays":"0.11/0/0.38/2.9","dsn":"2.0.0","status":"sent","comment":"250 2.0.0 OK 1539154772 az9-v6si5976496plb.190 - gsmtp"}],"message_id":"A40CF64D-7F2D-42E4-8A76-CBFFF64A6EB1@example.com","from":"test@example.com","size":"309891","nrcpt":"1","queue_status":"queue active"}
```

## Copyright

* Copyright(c) 2018- youyo
* License
* Apache License, Version 2.0
