#!/usr/bin/env bash

gcloud dataproc jobs submit spark \
    --properties spark.driver.cores=4,spark.driver.memory=18g,spark.executor.cores=4,spark.executor.memory=18g \
    --cluster akomar-test-2 \
    --class com.mozilla.telemetry.streaming.ErrorAggregator \
    --jars gs://akomar-test/telemetry-streaming-gcp-poc-assembly-0.1-SNAPSHOT.jar -- \
    --master yarn \
    --testPingsPath gs://akomar-test/test-pings \
    --outputPath gs://akomar-test/aggregator-output \
    --numParquetFiles 1