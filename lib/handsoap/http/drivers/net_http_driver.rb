# -*- coding: utf-8 -*-

module Handsoap
  module Http
    module Drivers
      class NetHttpDriver < AbstractDriver
        def self.load!
          require 'net/http'
          require 'uri'
        end

        def net_http_class_for_url(url)
          Net::HTTP
        end

        def send_http_request(request)
          url = request.url
          unless url.kind_of? ::URI::Generic
            url = ::URI.parse(url)
          end
          net_http_class = net_http_class_for_url(url)
          ::URI::Generic.send(:public, :path_query) # hackety hack
          path = url.path_query
          http_request = case request.http_method
                         when :get
                           net_http_class::Get.new(path)
                         when :post
                           net_http_class::Post.new(path)
                         when :put
                           net_http_class::Put.new(path)
                         when :delete
                           net_http_class::Delete.new(path)
                         else
                           raise "Unsupported request method #{request.http_method}"
                         end

          http_client = net_http_class.new(url.host, url.port)

          #http_client.read_timeout = 120
          http_client.open_timeout = Handsoap.timeout
          http_client.read_timeout = Handsoap.timeout

          http_client.use_ssl = true if url.scheme == 'https'

          if url.scheme == 'https'
            http_client.use_ssl = true

            if request.ssl_verify_mode
              http_client.verify_mode = request.ssl_verify_mode
              http_client.ca_file = request.trust_ca_file || OpenSSL::X509::DEFAULT_CERT_FILE
            end
          end

          if request.username && request.password
            # TODO: http://codesnippets.joyent.com/posts/show/1075
            http_request.basic_auth request.username, request.password
          end
          request.headers.each do |k, values|
            values.each do |v|
              http_request.add_field(k, v)
            end
          end
          http_request.body = request.body
          # require 'stringio'
          # debug_output = StringIO.new
          # http_client.set_debug_output debug_output
          http_response = http_client.start do |client|
            client.request(http_request)
          end
          # puts debug_output.string
          # hacky-wacky
          def http_response.get_headers
            @header.inject({}) do |h, (k, v)|
              h[k.downcase] = v
              h
            end
          end
          # net/http only supports basic auth. We raise a warning if the server requires something else.
          if http_response.code == 401 && http_response.get_headers['www-authenticate']
            auth_type = http_response.get_headers['www-authenticate'].chomp.match(/\w+/)[0].downcase
            if auth_type != "basic"
              raise "Authentication type #{auth_type} is unsupported by net/http"
            end
          end
          parse_http_part(http_response.get_headers, http_response.body, http_response.code)
        end
      end
    end
  end
end
