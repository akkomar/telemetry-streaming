package com.mozilla.telemetry.learning.federated

import org.apache.spark.sql.SparkSession

object ModelWriterTest {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("Model Writer Test")
      .config("spark.streaming.stopGracefullyOnShutdown", "true")
      .getOrCreate()

    val sink = new FederatedLearningSearchOptimizerS3Sink(
      "s3://net-mozaws-prod-us-west-2-data-public/awesomebar_study_test",
      "s3://mozilla-databricks-telemetry-test/federated_learning_test_checkpoint")

    sink.writeModel(ModelOutput(Array(1, 2, 3), 5))

    spark.version
  }
}
