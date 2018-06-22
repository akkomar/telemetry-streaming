#!/usr/bin/env bash
set -eux pipefail

source "$(dirname "$0")"/set_env.sh


create_job_json() {
cat << EOF
{
    "name": "Experiment enrollment aggregates to TestTube- streaming",
    "new_cluster": {
        "spark_version": "4.1.x-scala2.11",
        "node_type_id": "c3.2xlarge",
        "aws_attributes": {
            "first_on_demand": "1",
            "availability": "SPOT_WITH_FALLBACK",
            "instance_profile_arn": "${IAM_ROLE}",
            "zone_id": "us-west-2b"
        },
        "autoscale": {
            "min_workers": 1,
            "max_workers": 10
        },
        "ssh_public_keys": ["${SSH_PUBLIC_KEY}"],
        "spark_conf": {
            "spark.metrics.namespace": "telemetry-streaming",
            "spark.metrics.conf.*.sink.statsd.class": "org.apache.spark.metrics.sink.StatsdSink",
            "spark.sql.streaming.metricsEnabled": "true"
        },
        "custom_tags": {
            "App": "data",
            "Env": "databricks-dev",
            "Type": "streaming",
            "TelemetryJobName": "experiment_enrollments_to_testtube"
        }
    },
    "libraries": [{"jar": "s3://net-mozaws-data-us-west-2-ops-ci-artifacts/mozilla/telemetry-streaming/enrollments_to_testtube/telemetry-streaming.jar"}],
    "email_notifications": {
        "on_start": ["akomarzewski@mozilla.com", "dthorn@mozilla.com"],
        "on_success": ["akomarzewski@mozilla.com", "dthorn@mozilla.com"],
        "on_failure": ["akomarzewski@mozilla.com", "dthorn@mozilla.com"]
    },
    "spark_jar_task": {
        "main_class_name": "com.mozilla.telemetry.streaming.ExperimentEnrollmentsToTestTube",
        "parameters": ["--kafkaBroker","${KAFKA_BROKER}", "--url","https://firefox-test-tube.herokuapp.com/v2/enrollment/"]
    }
}
EOF
}

databricks jobs reset --job-id 450 --json "$(create_job_json)"
