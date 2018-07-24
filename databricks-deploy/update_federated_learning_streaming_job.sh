#!/usr/bin/env bash
set -eux pipefail

source "$(dirname "$0")"/set_env.sh


create_job_json() {
cat << EOF
{
    "name": "Federated learning - streaming",
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
            "TelemetryJobName": "federated_learning"
        },
        "cluster_log_conf": {
            "s3": {
                "destination" : "s3://mozilla-databricks-telemetry-test/federated_learning/logs",
                "region" : "us-west-2"
            }
        }
    },
    "libraries": [{"jar": "s3://net-mozaws-data-us-west-2-ops-ci-artifacts/mozilla/telemetry-streaming/frecency_aggregator/telemetry-streaming.jar"}],
    "email_notifications": {
        "on_start": ["akomarzewski@mozilla.com", "ssuh@mozilla.com"],
        "on_success": ["akomarzewski@mozilla.com", "ssuh@mozilla.com"],
        "on_failure": ["akomarzewski@mozilla.com", "ssuh@mozilla.com"]
    },
    "spark_jar_task": {
        "main_class_name": "com.mozilla.telemetry.streaming.FederatedLearningSearchOptimizer",
        "parameters": [
            "--kafkaBroker","${KAFKA_BROKER}",
            "--windowOffsetMinutes","26",
            "--checkpointPath","/tmp/federated_learning_spark_checkpoint_test",
            "--modelOutputBucket","net-mozaws-prod-us-west-2-data-public",
            "--modelOutputKey","awesomebar_study_test",
            "--stateCheckpointPath","s3://mozilla-databricks-telemetry-test/federated_learning_model_optimizer_checkpoint_test"
        ]
    }
}
EOF
}

databricks jobs reset --job-id 474 --json "$(create_job_json)"
