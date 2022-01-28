load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")

def artifacts():
    finagleVer = "21.2.0"
    circeVersion = "0.13.0"

    return [
        "io.swagger.parser.v3:swagger-parser:2.0.21",
        "com.github.pathikrit:better-files_2.13:3.9.1",
        "io.circe:circe-yaml_2.13:0.13.1",
        "org.scalatra.scalate:scalate-core_2.13:1.9.6",
        "commons-io:commons-io:2.8.0",
        "org.scala-sbt:util-logging_2.13:1.4.6",
        "com.typesafe.scala-logging:scala-logging_2.13:3.9.2",
        "org.scala-lang.modules:scala-parser-combinators_2.13:1.1.2",
        "com.twitter:finagle-http_2.13:" + finagleVer,
        "com.twitter:finagle-thrift_2.13:" + finagleVer,
        "com.twitter:finagle-stats_2.13:" + finagleVer,
        "com.twitter:util-core_2.13:" + finagleVer,
        "com.twitter:util-logging_2.13:" + finagleVer,
        "com.twitter:scrooge-core_2.13:" + finagleVer,
        "com.twitter:scrooge-generator_2.13:" + finagleVer,
        "com.twitter:scrooge-serializer_2.13:" + finagleVer,
        "io.circe:circe-generic-extras_2.13:" + circeVersion,
        "io.circe:circe-parser_2.13:" + circeVersion,
    ]

def install_maven_artifacts():
    # To dump all generated libraries and alias type
    # bazel query @maven//:all --output=build

    # Update using bazel run @unpinned_maven//:pin
    maven_install(
        excluded_artifacts = [
            "org.slf4j:slf4j-log4j12",
        ],
        artifacts = artifacts(),
        fetch_sources = False,
        version_conflict_policy = "pinned",
        fail_on_missing_checksum = False,
        #generate_compat_repositories = True,
        repositories = [
            "https://repo1.maven.org/maven2",
        ],
    )
