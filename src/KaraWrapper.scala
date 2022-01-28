package com.ea.rules_kara
import java.io.File

import com.ea.kara.Generator
import sbt.internal.util.ConsoleLogger
import sbt.util.Level

object KaraWrapper {

  type OptionMap = Map[Symbol, String]

  private val usage =
    """
    Usage: KaraWrapper [--thriftIncludes <path>] [--thriftSource <path>] [--serviceName <name>] [--sourcePath <path>] [--resourcePath <path>]
  """

  def main (args: Array[String]) = {
    if (args.length == 0) {
      println(usage)
      sys.exit(1)
    }


    val argList = args.toList
    print(argList)


    val thriftIncludes: scala.collection.mutable.Buffer[String] = scala.collection.mutable.Buffer()
    val thriftSources: scala.collection.mutable.Buffer[String] = scala.collection.mutable.Buffer()
    val serviceNames: scala.collection.mutable.Buffer[String] = scala.collection.mutable.Buffer()
    var sourcePath: String = ""
    var resourcePath: String = ""

    def nextOption(list: List[String]): Unit = {

      list match {
        case Nil => ()
        case "--thriftIncludes" :: value :: tail =>
          thriftIncludes += value.toString
          nextOption(tail)
        case "--thriftSource" :: value :: tail =>
          thriftSources += value.toString
          nextOption(tail)
        case "--serviceName" :: value :: tail =>
          serviceNames += value.toString
          nextOption(tail)
        case "--sourcePath" :: value :: tail =>
          sourcePath += value.toString
          nextOption(tail)
        case "--resourcePath" :: value :: tail =>
          resourcePath += value.toString
          nextOption(tail)
        case option :: tail => println("Unknown option " + option)
          sys.exit(1)
      }
    }

    nextOption(argList)

    thriftIncludes.map(new File(_))

    val logger = ConsoleLogger(new java.io.PrintWriter(System.out))
    logger.setLevel(Level.Debug)

    val genThriftIncludes = thriftIncludes.toSeq.map(new File(_))
    val genThriftSources = thriftSources.toSeq.map(new File(_))

    val generator = new Generator(
      thriftIncludes = genThriftIncludes,
      thriftSources = genThriftSources,
      serviceNames = serviceNames.toSeq,
      karaHeaders = Seq.empty,
      sourcePath = new File(sourcePath),
      resourcePath = new File(resourcePath)
    )(logger)
    generator.generateSources()
    generator.generateResources()
  }
}
