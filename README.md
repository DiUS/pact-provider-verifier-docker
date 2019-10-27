# Pact Provider Verification

This setup simplifies Pact Provider [verification](https://github.com/realestate-com-au/pact#2-tell-your-provider-that-it-needs-to-honour-the-pact-file-you-made-earlier) process in any language, by running the Pact Rake tasks in a separate Docker container.

**Features**:

* Verify Pacts against Pacts published to a [Pact Broker](https://github.com/bethesque/pact_broker)
* Verify local `*.json` Pacts for testing in a development environment
* Pre-configured Docker image with Ruby installed and a sane, default `src/Rakefile` keeping things DRY
* Works with Pact [provider states](https://github.com/realestate-com-au/pact/wiki/Provider-states) should you need them

## Prerequisites
* Docker
* Docker Compose
* Working Dockerfile for your API

## Examples

### Simple API

*Steps*:

1. Create an API and a corresponding Docker image for it
1. Publish Pacts to the Pact broker (or create local ones)
1. Create a `docker-compose.yml` file connecting your API to the Pact Verifier
1. Set the following required environment variables:
   * `pact_urls` - a comma delimited list of pact file urls
   * `provider_base_url` - the base url of the pact provider (i.e. your API)
1. Run `docker-compose build` and then `docker-compose up`

##### Sample docker-compose.yml file for a Node API exposed on port `4000`:

```
api:
  build: .
  command: npm start
  ports:
  - "4000:4000"

pactverifier:
  image: dius/pact-provider-verifier-docker
  links:
  - api:api
  volumes:
  - ./pact/pacts:/tmp/pacts                 # If you have local Pacts
  environment:
  - pact_urls=http://pact-host:9292/pacts/provider/MyAPI/consumer/MyConsumer/latest
  #- pact_urls=/tmp/pacts/foo-consumer.json # If you have local Pacts
  - provider_base_url=http://api:4000
```

### API with Provider States

Execute pact provider verification against a provider which implements the following:

* an http get endpoint which returns pact provider_states by consumer

		{
			"myConsumer": [
				"customer is logged in",
				"customer has a million dollars"
			]
		}

* an http post endpoint which sets the active pact consumer and provider state

		consumer=web&state=customer%20is%20logged%20in

The following environment variables required:

* `pact_urls` - a comma delimited list of pact file urls
* `provider_base_url` - the base url of the pact provider
* `provider_states_url` - the full url of the endpoint which returns provider states by consumer
* `provider_states_active_url` - the full url of the endpoint which sets the active pact consumer and provider state

#### (non-Docker) Usage

    $ bundle install
    $ bundle exec rake verify_pacts

#### Docker Compose Usage

##### Sample docker-compose.yml file

	api:
		build: .
		command: npm run-script pact-provider
		ports:
		- "4000"

	pactverifier:
		image: dius/pact-provider-verifier-docker
		links:
		- api
		environment:
		- pact_urls=http://pact-host:9292/pacts/provider/MyProvider/consumer/myConsumer/latest
		- provider_base_url=http://api4000:
		- provider_states_url=http://api:4000/provider-states
		- provider_states_active_url=http://api:4000/provider-states/active
