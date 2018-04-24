package com.mozilla.telemetry.test_utils

import java.io.File
import java.time.{ZoneId, ZonedDateTime}

import com.mozilla.telemetry.TestUtils
import org.apache.commons.io.FileUtils
import org.apache.spark.sql.{SaveMode, SparkSession}
import org.rogach.scallop.ScallopConf

// scalastyle:off
object PingGenerator {
  val log = org.apache.log4j.LogManager.getLogger(this.getClass)
  private val startTsNano = ZonedDateTime.of(2018, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC")).toInstant.toEpochMilli * 1000l * 1000l

  def main(args: Array[String]): Unit = {
    val conf = new Conf(args)

    val spark = SparkSession.builder()
      .master(conf.master())
      .appName("Synthetic ping generator")
      .config("spark.streaming.stopGracefullyOnShutdown", "true")
      .getOrCreate()
    import spark.implicits._

    if (conf.outputPath().startsWith("/tmp/")) {
      FileUtils.deleteDirectory(new File(conf.outputPath()))
    }

    val numberOfCrashPingsPerBatch = 22000
    val numberOfMainPingsPerBatch = 270000

    val numberOfCrashPingsPerDay = conf.crashPingsPerDay()
    val numberOfMainPingsPerDay = conf.mainPingsPerDay()

    val numberOfCrashPingFiles = numberOfCrashPingsPerDay / numberOfCrashPingsPerBatch
    val numberOfMainPingFiles = numberOfMainPingsPerDay / numberOfMainPingsPerBatch

    println(s"Starting data generation (${conf.args.sliding(2, 2).map(_.mkString(" ")).mkString(",")})...")

    val crashPingsDs = spark.sparkContext.parallelize(Seq[Int](), numberOfCrashPingFiles).mapPartitions { _ =>
      TestUtils.generateCrashMessages(numberOfCrashPingsPerBatch, timestamp = Some(startTsNano), randomize = true).map(m => FramedMessage("crash", m.toByteArray)).iterator
    }.toDS()
    crashPingsDs.write.option("compression", "gzip").mode(SaveMode.Append).partitionBy("docType").parquet(conf.outputPath())

    val mainPingsDs = spark.sparkContext.parallelize(Seq[Int](), numberOfMainPingFiles).mapPartitions { _ =>
      TestUtils.generateMainMessages(numberOfMainPingsPerBatch, timestamp = Some(startTsNano), randomize = true).map(m => FramedMessage("main", m.toByteArray)).iterator
    }.toDS()
    mainPingsDs.write.option("compression", "gzip").mode(SaveMode.Append).partitionBy("docType").parquet(conf.outputPath())

    println(s"Crash pings: ${crashPingsDs.count()}, partitions: ${crashPingsDs.rdd.partitions.length}")
    println(s"Main pings: ${mainPingsDs.count()}, partitions: ${mainPingsDs.rdd.partitions.length}")

    spark.close()
  }

  // --crashPingsPerDay 14000000 --mainPingsPerDay 218000000 --outputPath s3://net-mozaws-prod-us-west-2-pipeline-analysis/akomar/test-pings
  class Conf(arguments: Seq[String]) extends ScallopConf(arguments) {
    val master = opt[String](name = "master", default = Some("local[1]"))
    val outputPath = opt[String](name="outputPath", default = Some("/tmp/akomar/test-pings"))
    val crashPingsPerDay = opt[Int](name="crashPingsPerDay", default = Some(50000))
    val mainPingsPerDay = opt[Int](name="mainPingsPerDay", default = Some(300000))
    verify()
  }
}

case class FramedMessage(docType: String, value: Array[Byte])
