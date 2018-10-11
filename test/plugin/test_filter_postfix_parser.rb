require "helper"
require "fluent/plugin/filter_postfix_parser.rb"

class PostfixParserFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  #test "#filter_stream" do
  #end

  test '#parse' do
    filter = Fluent::Plugin::PostfixParserFilter.new()
    result = filter.parse('Oct 10 15:59:28 mail postfix/smtpd[1830]: C6E0DDB74006: client=example.com[127.0.0.1]')
    assert { result == {
      time: "Oct 10 15:59:28",
      hostname: "mail",
      process: "postfix/smtpd[1830]",
      queue_id: "C6E0DDB74006",
      messages: "client=example.com[127.0.0.1]",
      client_hostname: "example.com",
      client_ip: "127.0.0.1",
      message_id: nil,
      from: nil,
      size: nil,
      nrcpt: nil,
      queue_status: nil,
      to: nil,
      orig_to: nil,
      relay: nil,
      relay_hostname: nil,
      relay_ip: nil,
      relay_port: nil,
      delay: nil,
      delays: nil,
      dsn: nil,
      status: nil,
      comment: nil
    }}

    result = filter.parse('Oct 10 15:59:28 mail postfix/cleanup[1894]: C6E0DDB74006: message-id=<A40CF64D-7F2D-42E4-8A76-CBFFF64A6EB1@example.com>')
    assert { result == {
      time: "Oct 10 15:59:28",
      hostname: "mail",
      process: "postfix/cleanup[1894]",
      queue_id: "C6E0DDB74006",
      messages: "message-id=<A40CF64D-7F2D-42E4-8A76-CBFFF64A6EB1@example.com>",
      client_hostname: nil,
      client_ip: nil,
      message_id: "A40CF64D-7F2D-42E4-8A76-CBFFF64A6EB1@example.com",
      from: nil,
      size: nil,
      nrcpt: nil,
      queue_status: nil,
      to: nil,
      orig_to: nil,
      relay: nil,
      relay_hostname: nil,
      relay_ip: nil,
      relay_port: nil,
      delay: nil,
      delays: nil,
      dsn: nil,
      status: nil,
      comment: nil
    }}

    result = filter.parse('Oct 10 15:59:28 mail postfix/qmgr[18719]: C6E0DDB74006: from=<t_e-s+t=@example.com>, size=309891, nrcpt=1 (queue active)')
    assert { result == {
      time: "Oct 10 15:59:28",
      hostname: "mail",
      process: "postfix/qmgr[18719]",
      queue_id: "C6E0DDB74006",
      messages: "from=<t_e-s+t=@example.com>, size=309891, nrcpt=1 (queue active)",
      client_hostname: nil,
      client_ip: nil,
      message_id: nil,
      from: "t_e-s+t=@example.com",
      size: 309891,
      nrcpt: 1,
      queue_status: "queue active",
      to: nil,
      orig_to: nil,
      relay: nil,
      relay_hostname: nil,
      relay_ip: nil,
      relay_port: nil,
      delay: nil,
      delays: nil,
      dsn: nil,
      status: nil,
      comment: nil
    }}

    result = filter.parse('Oct 10 15:59:32 mail postfix/smtp[1874]: C6E0DDB74006: to=<test@example.ddd>, relay=example.ddd[192.168.0.30]:25, delay=3.4, delays=0.11/0/0.38/2.9, dsn=2.0.0, status=sent (250 2.0.0 OK 1539154772 az9-v6si5976496plb.190 - gsmtp)')
    assert { result == {
      time: "Oct 10 15:59:32",
      hostname: "mail",
      process: "postfix/smtp[1874]",
      queue_id: "C6E0DDB74006",
      messages: "to=<test@example.ddd>, relay=example.ddd[192.168.0.30]:25, delay=3.4, delays=0.11/0/0.38/2.9, dsn=2.0.0, status=sent (250 2.0.0 OK 1539154772 az9-v6si5976496plb.190 - gsmtp)",
      client_hostname: nil,
      client_ip: nil,
      message_id: nil,
      from: nil,
      size: nil,
      nrcpt: nil,
      queue_status: nil,
      to: "test@example.ddd",
      orig_to: nil,
      relay: "example.ddd[192.168.0.30]:25",
      relay_hostname: "example.ddd",
      relay_ip: "192.168.0.30",
      relay_port: 25,
      delay: 3.4,
      delays: "0.11/0/0.38/2.9",
      dsn: "2.0.0",
      status: "sent",
      comment: "250 2.0.0 OK 1539154772 az9-v6si5976496plb.190 - gsmtp"
    }}

    result = filter.parse('Oct 10 15:59:32 mail postfix/smtp[1874]: C6E0DDB74006: to=<test@ex-ample.ddd>, relay=virtual, delay=3.4, delays=0.11/0/0.38/2.9, dsn=2.0.0, status=sent (delivered to maildir)')
    assert { result == {
      time: "Oct 10 15:59:32",
      hostname: "mail",
      process: "postfix/smtp[1874]",
      queue_id: "C6E0DDB74006",
      messages: "to=<test@ex-ample.ddd>, relay=virtual, delay=3.4, delays=0.11/0/0.38/2.9, dsn=2.0.0, status=sent (delivered to maildir)",
      client_hostname: nil,
      client_ip: nil,
      message_id: nil,
      from: nil,
      size: nil,
      nrcpt: nil,
      queue_status: nil,
      to: "test@ex-ample.ddd",
      orig_to: nil,
      relay: "virtual",
      relay_hostname: nil,
      relay_ip: nil,
      relay_port: nil,
      delay: 3.4,
      delays: "0.11/0/0.38/2.9",
      dsn: "2.0.0",
      status: "sent",
      comment: "delivered to maildir"
    }}

    result = filter.parse('Oct 10 15:59:32 mail postfix/smtp[1874]: C6E0DDB74006: to=<test@example.ddd>, orig_to=<root>, relay=local, delay=3.4, delays=0.11/0/0.38/2.9, dsn=2.0.0, status=sent (delivered to maildir)')
    assert { result == {
      time: "Oct 10 15:59:32",
      hostname: "mail",
      process: "postfix/smtp[1874]",
      queue_id: "C6E0DDB74006",
      messages: "to=<test@example.ddd>, orig_to=<root>, relay=local, delay=3.4, delays=0.11/0/0.38/2.9, dsn=2.0.0, status=sent (delivered to maildir)",
      client_hostname: nil,
      client_ip: nil,
      message_id: nil,
      from: nil,
      size: nil,
      nrcpt: nil,
      queue_status: nil,
      to: "test@example.ddd",
      orig_to: "root",
      relay: "local",
      relay_hostname: nil,
      relay_ip: nil,
      relay_port: nil,
      delay: 3.4,
      delays: "0.11/0/0.38/2.9",
      dsn: "2.0.0",
      status: "sent",
      comment: "delivered to maildir"
    }}

    result = filter.parse('Oct 10 15:59:32 mail postfix/qmgr[18719]: C6E0DDB74006: removed')
    assert { result == {
      time: "Oct 10 15:59:32",
      hostname: "mail",
      process: "postfix/qmgr[18719]",
      queue_id: "C6E0DDB74006",
      messages: "removed",
      client_hostname: nil,
      client_ip: nil,
      message_id: nil,
      from: nil,
      size: nil,
      nrcpt: nil,
      queue_status: nil,
      to: nil,
      orig_to: nil,
      relay: nil,
      relay_hostname: nil,
      relay_ip: nil,
      relay_port: nil,
      delay: nil,
      delays: nil,
      dsn: nil,
      status: nil,
      comment: nil
    }}

  end

  private

  DEFAULT_CONF = %q{
    key message
  }

  def create_driver(conf = DEFAULT_CONF)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::PostfixParserFilter).configure(conf)
  end
end
