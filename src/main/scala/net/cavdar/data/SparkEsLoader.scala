package net.cavdar.data

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types.{DataTypes, StructField, StructType}
import org.elasticsearch.spark.sql._

object SparkEsLoader {

  case class Record(key: Int, value: String)

  def main(args: Array[String]) {
    val spark = SparkSession
      .builder()
      .appName("Spark-Es-Loader")
      .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
      .config("spark.sql.autoBroadcastJoinThreshold", "300000000")
      .config("spark.es.nodes", "elasticsearch:9200")
      .config("spark.es.batch.size.bytes", "2mb")
      .config("spark.es.batch.size.entries", "0")
      .config("spark.es.batch.write.refresh", "false")
      .config("spark.es.batch.write.retry.count", "1")
      .config("spark.es.mapping.id", "key")
      .getOrCreate()

    import spark.implicits._

    val schema = StructType(
      Array(
        StructField("key", DataTypes.IntegerType),
        StructField("value", DataTypes.StringType)
      )
    )

    val logs = spark
      .read
      .schema(schema)
      .option("header", false)
      .csv("/data/sample.log")
      .as[Record]

    // change the number of partitions if necessary to control the parallelism
    val logsRepartitioned = logs.repartition(10)

    logsRepartitioned.saveToEs("logs/_doc")

    spark.stop()
  }
}
