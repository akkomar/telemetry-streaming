#!/usr/bin/env bash

gcloud dataproc jobs submit spark --cluster akomar-test-data-generation \
    --class com.mozilla.telemetry.test_utils.PingGenerator \
    --jars gs://akomar-test/telemetry-streaming-gcp-poc-assembly-0.1-SNAPSHOT.jar -- \
    --master yarn \
    --crashPingsPerDay 14000000 \
    --mainPingsPerDay 218000000 \
    --outputPath gs://akomar-test/test-pings