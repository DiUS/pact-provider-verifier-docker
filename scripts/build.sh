#!/bin/bash -e

if [ -n "$BUILD_NUMBER" ]; then
  echo "Building container v${BUILD_NUMBER}"
  docker build -t dius/pact-provider-verifier:$BUILD_NUMBER .
  docker tag -f dius/pact-provider-verifier:$BUILD_NUMBER dius/pact-provider-verifier:latest
  docker push dius/pact-provider-verifier:$BUILD_NUMBER
else
  echo "Building container with tag 'latest'"
  docker build -t dius/pact-provider-verifier:latest .
fi
docker push dius/pact-provider-verifier:latest
