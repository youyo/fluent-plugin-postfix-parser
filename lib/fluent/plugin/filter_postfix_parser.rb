#
# Copyright 2018- youyo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/filter"
require 'pp'

module Fluent
  module Plugin
    class PostfixParserFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("postfix_parser", self)

      config_param :key, :string, :default => 'message'

      def configure(conf)
        super
        @data = {}
      end

=begin
      def filter(tag, time, record)
        line = record[@key]
        return record unless line

        parsed = parse(line)

        if parsed[:client_hostname]
          @data[parsed[:queue_id]] = {
            time: parsed[:time],
            hostname: parsed[:hostname],
            process: parsed[:process],
            queue_id: parsed[:queue_id],
            client_hostname: parsed[:client_hostname],
            client_ip: parsed[:client_ip],
            messages: []
          }
        end

        if parsed[:message_id]
          @data[parsed[:queue_id]][:message_id] = parsed[:message_id]
        end

        if parsed[:from]
          @data[parsed[:queue_id]][:from] = parsed[:from]
          @data[parsed[:queue_id]][:size] = parsed[:size]
          @data[parsed[:queue_id]][:nrcpt] = parsed[:nrcpt]
          @data[parsed[:queue_id]][:queue_status] = parsed[:queue_status]
        end

        if parsed[:to]
          @data[parsed[:queue_id]][:messages].push({
            time: parsed[:time],
            to: parsed[:to],
            relay_hostname: parsed[:relay_hostname],
            relay_ip: parsed[:relay_ip],
            relay_port: parsed[:relay_port],
            delay: parsed[:delay],
            delays: parsed[:delays],
            dsn: parsed[:dsn],
            status: parsed[:status],
            comment: parsed[:comment],
          })
        end

        if parsed[:messages] == "removed"
          pp @data
          return @data[:queue_id]
        end

        return nil

      rescue => e
        log.warn "failed to parse a postfix log: #{line}", :error_class => e.class, :error => e.message
        log.warn_backtrace
        record
      end
=end

      def filter_stream(tag, es)
        new_es = MultiEventStream.new
        es.each { |time, record|
          line = record[@key]
          return record unless line

          parsed = parse(line)

          if parsed[:client_hostname]
            @data[parsed[:queue_id]] = {
              time: parsed[:time],
              hostname: parsed[:hostname],
              process: parsed[:process],
              queue_id: parsed[:queue_id],
              client_hostname: parsed[:client_hostname],
              client_ip: parsed[:client_ip],
              messages: []
            }
          end

          if parsed[:message_id]
            @data[parsed[:queue_id]][:message_id] = parsed[:message_id]
          end

          if parsed[:from]
            @data[parsed[:queue_id]][:from] = parsed[:from]
            @data[parsed[:queue_id]][:size] = parsed[:size]
            @data[parsed[:queue_id]][:nrcpt] = parsed[:nrcpt]
            @data[parsed[:queue_id]][:queue_status] = parsed[:queue_status]
          end

          if parsed[:to]
            @data[parsed[:queue_id]][:messages].push({
              time: parsed[:time],
              to: parsed[:to],
              relay_hostname: parsed[:relay_hostname],
              relay_ip: parsed[:relay_ip],
              relay_port: parsed[:relay_port],
              delay: parsed[:delay],
              delays: parsed[:delays],
              dsn: parsed[:dsn],
              status: parsed[:status],
              comment: parsed[:comment],
            })
          end

          new_es.add(time, @data[parsed[:queue_id]]) if parsed[:messages] == "removed"
        }

        return new_es

      rescue => e
        log.warn "failed to parse a postfix log: #{line}", :error_class => e.class, :error => e.message
        log.warn_backtrace
        record
      end

      private
      def parse(text)
        client_reg     = '(?:client=(.+)\[(.+)\])'
        message_id_reg = '(?:message-id=<(.+)>)'
        from_reg       = '(?:from=<(.+@.+)>, size=(\d*), nrcpt=(\d+) \((.*)\))'
        to_reg         = '(?:to=<(.+@.+)>, )'
        relay_reg      = '(?:relay=(.+)\[(.+)\]:(\d{1,2}), )'
        delay_reg      = '(?:delay=([\d\.]+), )'
        delays_reg     = '(?:delays=([\d\.\/]*), )'
        dsn_reg        = '(?:dsn=([\d\.]+), )'
        status_reg     = '(?:status=([a-z]+) )'
        comment_reg    = '(?:\((.*)\))'
        messages       = "(#{client_reg}?#{message_id_reg}?#{from_reg}?#{to_reg}?#{relay_reg}?#{delay_reg}?#{delays_reg}?#{dsn_reg}?#{status_reg}?#{comment_reg}?.*)"

        time_reg     = '([A-Za-z]{3}\s+[0-9]{1,2} [0-9]{2}:[0-9]{2}:[0-9]{2})'
        hostname_reg = '([0-9A-Za-z\.]*)'
        process_reg  = '(postfix\/[a-z]*\[[0-9]{1,5}\])'
        queue_id_reg = '([0-9A-Z]*)'
        reg          = "#{time_reg} #{hostname_reg} #{process_reg}(?::\s)#{queue_id_reg}?(?:: )?#{messages}"

        result = text.scan(/#{reg}/)[0]
        return {
          time: result[0],
          hostname: result[1],
          process: result[2],
          queue_id: result[3],
          messages: result[4],
          client_hostname: result[5],
          client_ip: result[6],
          message_id: result[7],
          from: result[8],
          size: result[9],
          nrcpt: result[10],
          queue_status: result[11],
          to: result[12],
          relay_hostname: result[13],
          relay_ip: result[14],
          relay_port: result[15],
          delay: result[16],
          delays: result[17],
          dsn: result[18],
          status: result[19],
          comment: result[20]
        }

      end

    end
  end
end
