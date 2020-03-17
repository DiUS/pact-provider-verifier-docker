require 'net/https'
require 'faraday_middleware'
require 'json'

def get_json(path)
    case path
    when URI::regexp
        return get_json_from_server(path)
    else
        return get_json_from_local_file(path)
    end
end

def get_json_from_server(path)
    url = URI.parse(path)
    conn = Faraday.new("#{url.scheme}://#{url.host}:#{url.port}", {
        "Authorization" => "Bearer #{ENV['broker_token']}"
      }
    ) do |c|
        c.use FaradayMiddleware::ParseJson
        c.use Faraday::Adapter::NetHttp 
    end

    response = conn.get(url.request_uri)
    return response.body
end

def get_json_from_local_file(path)
    file = File.read(path)
    return JSON.parse(file)
end