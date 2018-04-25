#!/usr/bin/env bash
set -eux pipefail

source "$(dirname "$0")"/set_env.sh

DBFS_JAR_DIR=telemetry-streaming-lib-gcp-poc
JAR_NAME=telemetry-streaming-gcp-poc-assembly-0.1-SNAPSHOT.jar


create_job_json() {
cat << EOF
{
    "run_name": "Data generator",
    "new_cluster": {
        "spark_version": "3.5.x-scala2.11",
        "node_type_id": "i3.xlarge",
        "aws_attributes": {
            "availability": "SPOT_WITH_FALLBACK",
            "instance_profile_arn": "${IAM_ROLE}",
            "zone_id": "us-west-2b"
        },
        "autoscale": {
            "min_workers": 1,
            "max_workers": 80
        },
        "ssh_public_keys": ["${SSH_PUBLIC_KEY}"]
    },
    "libraries": [{"jar": "dbfs:/${DBFS_JAR_DIR}/${JAR_NAME}"}],
    "email_notifications": {
        "on_start": [],
        "on_success": [],
        "on_failure": []
    },
    "spark_jar_task": {
        "main_class_name": "com.mozilla.telemetry.test_utils.PingGenerator",
        "parameters": [
            "--crashPingsPerDay", "14000000",
            "--mainPingsPerDay", "218000000",
            "--outputPath",  "s3://net-mozaws-prod-us-west-2-pipeline-analysis/akomar/test-pings"
            ]
    }
}
EOF
}

curl -s \
    -H "Authorization: Bearer $DATABRICKS_TOKEN" \
    -X POST \
    -H 'Content-Type: application/json' \
    -d "$(create_job_json)" \
    https://dbc-caf9527b-e073.cloud.databricks.com/api/2.0/jobs/runs/submit
