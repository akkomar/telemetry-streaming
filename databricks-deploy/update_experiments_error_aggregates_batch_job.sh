#!/usr/bin/env bash
set -eux pipefail

source "$(dirname "$0")"/set_env.sh

OUTPUT_PATH=s3://mozilla-databricks-telemetry-test/experiments_error_aggregates_test



create_job_json() {
cat << EOF
{
    "name": "Experiments error aggregates backfill",
    "new_cluster": {
        "spark_version": "4.1.x-scala2.11",
        "node_type_id": "i3.xlarge",
        "aws_attributes": {
            "first_on_demand": "1",
            "availability": "SPOT_WITH_FALLBACK",
            "instance_profile_arn": "${IAM_ROLE}",
            "zone_id": "us-west-2b"
        },
        "autoscale": {
            "min_workers": 1,
            "max_workers": 50
        },
        "ssh_public_keys": ["${SSH_PUBLIC_KEY}"]
    },
    "libraries": [{"jar": "s3://net-mozaws-data-us-west-2-ops-ci-artifacts/mozilla/telemetry-streaming/refactor_fix/telemetry-streaming.jar"}],
    "email_notifications": {
        "on_start": ["akomarzewski@mozilla.com"],
        "on_success": ["akomarzewski@mozilla.com"],
        "on_failure": ["akomarzewski@mozilla.com"]
    },
    "spark_jar_task": {
        "main_class_name": "com.mozilla.telemetry.streaming.ExperimentsErrorAggregator",
        "parameters": ["--from","20180607", "--to","20180607", "--outputPath","${OUTPUT_PATH}"]
    }
}
EOF
}

databricks jobs reset --job-id 434 --json "$(create_job_json)"
