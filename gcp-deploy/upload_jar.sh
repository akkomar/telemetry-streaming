#!/usr/bin/env bash

gsutil rm gs://akomar-test/telemetry-streaming-gcp-poc-assembly-0.1-SNAPSHOT.jar

gsutil cp target/scala-2.11/telemetry-streaming-gcp-poc-assembly-0.1-SNAPSHOT.jar gs://akomar-test/
