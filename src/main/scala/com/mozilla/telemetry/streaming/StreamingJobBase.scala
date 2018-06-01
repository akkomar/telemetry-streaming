package com.mozilla.telemetry.streaming

import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import java.time.{Clock, LocalDate}

abstract class StreamingJobBase {
  val queryName: String

  /**
    * S3 output prefix with version number
    */
  val outputPrefix: String = ""

  /**
    * Date format for parsing input arguments and formatting partitioning columns
    */
  val DateFormat = "yyyyMMdd"
  val DateFormatter = DateTimeFormatter.ofPattern(DateFormat)
  val clock: Clock = Clock.systemUTC()

  /**
    * Generates list of dates for querying `com.mozilla.telemetry.heka.Dataset`
    * If `to` is empty, uses yesterday as the upper bound.
    *
    * @param from start date, in "yyyyMMdd" format
    * @param to   (optional) end date, in "yyyyMMdd" format
    * @return sequence of dates formatted as "yyyyMMdd" strings
    */
  def datesBetween(from: String, to: Option[String]): Seq[String] = {
    val parsedFrom: LocalDate = LocalDate.parse(from, DateFormatter)
    val parsedTo: LocalDate = to match {
      case Some(t) => LocalDate.parse(t, DateFormatter)
      case _ => LocalDate.now(clock).minusDays(1)
    }
    (0L to ChronoUnit.DAYS.between(parsedFrom, parsedTo)).map { offset =>
      parsedFrom.plusDays(offset).format(DateFormatter)
    }
  }
}
