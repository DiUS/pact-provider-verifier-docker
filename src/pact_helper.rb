require './json_helper'

# Responsible for making the call to the provider state server to set up the state
if ENV['provider_states_url']
    module ProviderStateServerClient
        def set_up_state provider_state
            puts "Setting up provider state '#{provider_state}' for consumer '#{ENV['pact_consumer']}' using provider state server at #{ENV['provider_states_active_url']}"
            conn = Faraday.new(:url => ENV['provider_states_active_url']) do |faraday|
              faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
            end
            conn.post do |req|
              req.headers["Content-Type"] = "application/json"
              req.body = JSON.dump ({"consumer" => ENV['pact_consumer'], "state" => provider_state })
            end
        end
    end

    Pact.configure do | config |
      config.include ProviderStateServerClient
    end

    # get the consumer provider states from the provider
    provider_states = get_json(ENV['provider_states_url'])

    # register the consumer provider states with pact
    provider_states.keys.each do |consumer|
        Pact.provider_states_for consumer do
            provider_states[consumer].each do |provider_state|
                provider_state provider_state do
                    set_up do
                        set_up_state provider_state
                    end
                end
            end
        end
    end
end
