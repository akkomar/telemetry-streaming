#!/usr/bin/env bash
set -eux pipefail

source "$(dirname "$0")"/set_env.sh


echo "Building jar..."
sbt clean assembly

echo "Deploying jar to dev branch directory on Databricks cluster..."
databricks fs ls ${DBFS_BRANCH_DEV_JAR_DIR} || databricks fs mkdirs ${DBFS_BRANCH_DEV_JAR_DIR}
databricks fs ls ${DBFS_BRANCH_DEV_JAR_DIR}/${JAR_NAME} && databricks fs rm ${DBFS_BRANCH_DEV_JAR_DIR}/${JAR_NAME}
databricks fs cp target/scala-2.11/${JAR_NAME} ${DBFS_BRANCH_DEV_JAR_DIR}/${JAR_NAME}
