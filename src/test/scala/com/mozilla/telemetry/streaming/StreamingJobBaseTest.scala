package com.mozilla.telemetry.streaming

import java.time.{Clock, LocalDate, ZoneId}

import org.scalatest.{FlatSpec, Matchers}

class StreamingJobBaseTest extends FlatSpec with Matchers {
  private val base = new StreamingJobBase {
    override val queryName = ""
    override val outputPrefix = ""
    override val clock: Clock = Clock.fixed(
      LocalDate.of(2018, 4, 5).atStartOfDay(ZoneId.of("UTC")).toInstant, ZoneId.of("UTC"))
  }

  "Base streaming job" should "generate range of parsed dates for querying Dataset API" in {
    base.datesBetween("20180401", Some("20180401")) should contain theSameElementsInOrderAs Seq("20180401")
    base.datesBetween("20180401", Some("20180403")) should contain theSameElementsInOrderAs Seq("20180401", "20180402", "20180403")
    base.datesBetween("20180403", None) should contain theSameElementsInOrderAs Seq("20180403", "20180404")
  }
}
