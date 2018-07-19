#!/usr/bin/env bash
set -eux pipefail

source "$(dirname "$0")"/set_env.sh


create_job_json() {
cat << EOF
{
    "name": "model write test",
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
            "max_workers": 2
        },
        "ssh_public_keys": ["${SSH_PUBLIC_KEY}"]
    },
    "libraries": [{"jar": "dbfs:/model-write-test/telemetry-streaming-assembly-0.1-SNAPSHOT.jar"}],
    "spark_jar_task": {
        "main_class_name": "com.mozilla.telemetry.learning.federated.ModelWriterTest",
        "parameters": []
    }
}
EOF
}

databricks jobs reset --job-id 477 --json "$(create_job_json)"
