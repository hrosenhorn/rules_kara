workspace(name = "rules_kara")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")

skylib_version = "1.0.3"

http_archive(
    name = "bazel_skylib",
    sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
    type = "tar.gz",
    url = "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib-{}.tar.gz".format(skylib_version, skylib_version),
)

rules_scala_version = "0f55e9f8cff6494bbff7cd57048d732286a520f5"

http_archive(
    name = "io_bazel_rules_scala",
    sha256 = "9d660e07b7477e703769547dbf457de38279f22784db48925c541223563fea32",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
)

# Stores Scala version and other configuration
# 2.12 is a default version, other versions can be use by passing them explicitly:
# scala_config(scala_version = "2.11.12")
load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")

scala_config(scala_version = "2.13.3")

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")

scala_repositories()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")

scala_register_toolchains()

# optional: setup ScalaTest toolchain and dependencies
load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")

scalatest_repositories()

scalatest_toolchain()

RULES_JVM_EXTERNAL_TAG = "4.1"

RULES_JVM_EXTERNAL_SHA = ""

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("//:repository.bzl", "install_maven_artifacts")

install_maven_artifacts()

load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge")

twitter_scrooge(
    libthrift = "//thrift:deps",
    scrooge_core = "@maven//:com_twitter_scrooge_core_2_13",
    scrooge_generator = "@maven//:com_twitter_scrooge_generator_2_13",
    util_core = "@maven//:com_twitter_util_core_2_13",
    util_logging = "@maven//:com_twitter_util_logging_2_13",
)

load("//:deps.bzl", "kara_repositories")

kara_repositories()
