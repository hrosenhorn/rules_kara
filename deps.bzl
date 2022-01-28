load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

def kara_repositories():
    excludes = native.existing_rules().keys()

    if "kara" not in excludes:
        new_git_repository(
            name = "kara",
            build_file_content = """
filegroup(
    name = "sources",
    srcs = glob([
        "src/main/scala/com/ea/kara/bindings/*.scala",
        "src/main/scala/com/ea/kara/extensions/*.scala",
        "src/main/scala/com/ea/kara/oas/*.scala",
        "src/main/scala/com/ea/kara/parse/*.scala",
        "src/main/scala/com/ea/kara/write/*.scala",
        "src/main/scala/com/ea/kara/Context.scala",
        "src/main/scala/com/ea/kara/Constants.scala",
        "src/main/scala/com/ea/kara/Generator.scala",
    ]),
    visibility = ["//visibility:public"],
)
filegroup(
    name = "resources",
    srcs = glob([
        "src/main/resources/**/*",
    ]),
    visibility = ["//visibility:public"],
)
    """,
            commit = "234ccbcc787a265381b6f2424efa8400299b9fcf",
            remote = "https://github.com/electronicarts/kara.git",
        )
