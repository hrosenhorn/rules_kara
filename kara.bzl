load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
load("@io_bazel_rules_scala//thrift:thrift_info.bzl", "ThriftInfo")

def _kara_generator_impl(ctx):
    swagger_dir = ctx.actions.declare_directory("swagger")
    root = swagger_dir.dirname  # ../

    outputs = [swagger_dir]  # All the files produced by this rule
    class_names = []
    args = []


    thrift_deps = [dep[ThriftInfo] for dep in ctx.attr.deps]

    # Extract each thrift_library jars into corresponding directory to satisfy how the Generator wants file paths
    work_dirs = []

    for index, dep in enumerate(thrift_deps):
        src = dep.srcs.to_list()[0] # Maybe incorrect assumption that a thrift lib only contains one jar?

        work_dir = ctx.actions.declare_directory("work_%s" % (index))
        ctx.actions.run_shell(
            tools = [ctx.executable._zipper],
            inputs = [src],
            outputs = [work_dir],
            mnemonic = "ThriftUnpacker",
            command = """
{zipper} x {path} -d {out}
    """.format(
                out = work_dir.path,
                zipper = ctx.executable._zipper.path,
                path = src.path,
            ),
            progress_message = "Unpack thrift library %s" % src.path,
        )
        work_dirs.append(work_dir)

    # Append all swagger resources t outputs
    for entry in ctx.outputs.swagger_resources:
        outputs.append(entry)

    # Declare the files produced by the Kara generator as outputs
    for package_name in ctx.attr.service_names.keys():
        service = ctx.attr.service_names[package_name]
        class_name = service.split(".")[-1]
        class_names.append(class_name)

        out_service = ctx.actions.declare_file("com/ea/kara/generated/%s/Http%s.scala" % (package_name, class_name))
        out_package = ctx.actions.declare_file("com/ea/kara/generated/%s/package.scala" % (package_name))
        oas_path = "swagger/" + service + "/service.oas"
        oas_file = ctx.actions.declare_file(oas_path)

        outputs.append(oas_file)
        outputs.append(out_service)
        outputs.append(out_package)

        args.append("--serviceName")
        args.append(service)

    source = ctx.attr.src.files.to_list()[0]

    args.append("--thriftSource")
    args.append(source.basename)
    args.append("--thriftIncludes")
    args.append(source.dirname)

    work_dirs.append(source)

    for work_dir in  work_dirs:
        args.append("--thriftIncludes")
        args.append(work_dir.path)


    # These specify where the Kara Generator should use as prefix when writing files
    args.append("--sourcePath")
    args.append(root)
    args.append("--resourcePath")
    args.append(root)

    # Run the Kara generator
    ctx.actions.run(
        inputs = work_dirs,
        outputs = outputs,
        arguments = args,
        progress_message = "Generating Kara bindings for %s" % ",".join(class_names),
        executable = ctx.executable.wrapper,
    )

    return DefaultInfo(files = depset(outputs), runfiles = ctx.runfiles(dep.srcs.to_list()))

kara_generator = rule(
    _kara_generator_impl,
    attrs = {
        "deps": attr.label_list(providers = [ThriftInfo]),
        "src": attr.label(allow_files = [".thrift"]),
        "service_names": attr.string_dict(),
        "wrapper": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@rules_kara//src:wrapper"),
        ),
        "swagger_resources": attr.output_list(
            doc = "A list of swagger resources the Kara generator produces",
        ),
        "_zipper": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@bazel_tools//tools/zip:zipper"),
            allow_files = True,
        ),
    },
)

def kara_library(name, src, thrift_deps, deps, service_names):
    kara_generator(
        name = name + "_generated",
        service_names = service_names,
        src = src,
        deps = thrift_deps,
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
