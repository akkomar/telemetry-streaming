#!/usr/bin/env bash
set -eux pipefail

source "$(dirname "$0")"/set_env.sh

OUTPUT_PATH=s3://mozilla-databricks-telemetry-test/enrollment_aggregates
CHECKPOINT_PATH=s3://mozilla-databricks-telemetry-test/enrollment_aggregates_checkpoint


create_job_json() {
cat << EOF
{
    "name": "Experiment enrollment aggregates - streaming",
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
            "Env": "databricks-prod",
            "Type": "streaming",
            "TelemetryJobName": "experiment_enrollments"
        }
    },
    "libraries": [{"jar": "s3://net-mozaws-data-us-west-2-ops-ci-artifacts/mozilla/telemetry-streaming/tags/v1.0.4/telemetry-streaming.jar"}],
    "email_notifications": {
        "on_start": ["akomarzewski@mozilla.com", "dthorn@mozilla.com"],
        "on_success": ["akomarzewski@mozilla.com", "dthorn@mozilla.com"],
        "on_failure": ["akomarzewski@mozilla.com", "dthorn@mozilla.com"]
    },
    "spark_jar_task": {
        "main_class_name": "com.mozilla.telemetry.streaming.ExperimentEnrollmentsAggregator",
        "parameters": ["--kafkaBroker","${KAFKA_BROKER}", "--outputPath","${OUTPUT_PATH}", "--checkpointPath","${CHECKPOINT_PATH}"]
    }
}
EOF
}

databricks jobs reset --job-id 432 --json "$(create_job_json)"
