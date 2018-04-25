#!/usr/bin/env bash
set -eux pipefail

DBFS_JAR_DIR=telemetry-streaming-lib-gcp-poc
JAR_NAME=telemetry-streaming-gcp-poc-assembly-0.1-SNAPSHOT.jar

databricks fs ls dbfs:/${DBFS_JAR_DIR} || databricks fs mkdirs dbfs:/${DBFS_JAR_DIR}
databricks fs ls dbfs:/${DBFS_JAR_DIR}/${JAR_NAME} && databricks fs rm dbfs:/${DBFS_JAR_DIR}/${JAR_NAME}
databricks fs cp target/scala-2.11/${JAR_NAME} dbfs:/${DBFS_JAR_DIR}/${JAR_NAME}