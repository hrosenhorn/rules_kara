load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
load("@io_bazel_rules_scala//thrift:thrift_info.bzl", "ThriftInfo")

def _kara_generator_impl(ctx):
    swagger_dir = ctx.actions.declare_directory("swagger")
    root = swagger_dir.dirname  # ../

    outputs = [swagger_dir]  # All the files produced by this rule
    class_names = []
    args = []

    for entry in ctx.outputs.swagger_resources:
        outputs.append(entry)

    for key in ctx.attr.service_names.keys():
        service = ctx.attr.service_names[key]
        class_name = service.split(".")[-1]
        class_names.append(class_name)

        out_service = ctx.actions.declare_file("com/ea/kara/generated/%s/Http%s.scala" % (ctx.attr.package_name, class_name))
        out_package = ctx.actions.declare_file("com/ea/kara/generated/%s/package.scala" % (ctx.attr.package_name))
        outputs.append(out_service)
        outputs.append(out_package)

        args.append("--serviceName")
        args.append(service)

    for name in ctx.files.srcs:
        args.append("--thriftSource")
        args.append(name.basename)
        args.append("--thriftIncludes")
        args.append(name.dirname)

    # These specify where the Kara Generator should use as prefix when writing files
    args.append("--sourcePath")
    args.append(root)
    args.append("--resourcePath")
    args.append(root)

    ctx.actions.run(
        inputs = ctx.files.srcs,
        outputs = outputs,
        arguments = args,
        progress_message = "Generating Kara bindings for %s" % ",".join(class_names),
        executable = ctx.executable.wrapper,
    )

    return DefaultInfo(files = depset(outputs))

kara_generator = rule(
    _kara_generator_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".thrift"]),
        "service_names": attr.string_dict(),
        "package_name": attr.string(mandatory = True),
        "wrapper": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@rules_kara//src:wrapper"),
        ),
        "swagger_resources": attr.output_list(
            doc = "A list of swagger resources the Kara generator produces",
        ),
    },
)

def kara_library(name, package_name, srcs, service_names, deps):
    kara_generator(
        name = name + "_generated",
        package_name = package_name,
        service_names = service_names,
        srcs = srcs,
        swagger_resources = [
            ":swagger/index.html",
            ":swagger/favicon-16x16.png",
            ":swagger/favicon-32x32.png",
            ":swagger/oauth2-redirect.html",
            ":swagger/swagger-ui.css",
            ":swagger/swagger-ui.js",
            ":swagger/swagger-ui-bundle.js",
            ":swagger/swagger-ui-standalone-preset.js",
        ],
    )

    scala_library(
        name = name,
        srcs = [":" + name + "_generated"],
        unused_dependency_checker_mode = "off",
        resource_strip_prefix = native.package_name(),
        visibility = ["//visibility:public"],
        resources = [
            ":swagger/index.html",
            ":swagger/favicon-16x16.png",
            ":swagger/favicon-32x32.png",
            ":swagger/oauth2-redirect.html",
            ":swagger/swagger-ui.css",
            ":swagger/swagger-ui.js",
            ":swagger/swagger-ui-bundle.js",
            ":swagger/swagger-ui-standalone-preset.js",
        ],
        deps = [
            "@maven//:org_apache_thrift_libthrift",
            "@maven//:io_circe_circe_core_2_13",
            "@maven//:com_twitter_scrooge_core_2_13",
            "@maven//:io_circe_circe_parser_2_13",
            "@maven//:io_circe_circe_generic_2_13",
            "@maven//:com_twitter_finagle_thrift_2_13",
            "@maven//:org_typelevel_cats_core_2_13",
            "@maven//:com_twitter_finagle_base_http_2_13",
            "@maven//:com_twitter_finagle_core_2_13",
        ] + deps,
    )
