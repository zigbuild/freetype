
const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    const lib = b.addStaticLibrary(.{
        .name = "freetype",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibC();

    lib.addIncludePath("include");
    lib.addIncludePath("src");

    const FreeType_Sources = &[_][]const u8 {
        "src/autofit/autofit.c",
        "src/base/ftbase.c",
        "src/base/ftbbox.c",
        "src/base/ftbdf.c",
        "src/base/ftbitmap.c",
        "src/base/ftcid.c",
        "src/base/ftfstype.c",
        "src/base/ftgasp.c",
        "src/base/ftglyph.c",
        "src/base/ftgxval.c",
        "src/base/ftinit.c",
        "src/base/ftmm.c",
        "src/base/ftotval.c",
        "src/base/ftpatent.c",
        "src/base/ftpfr.c",
        "src/base/ftstroke.c",
        "src/base/ftsynth.c",
        "src/base/fttype1.c",
        "src/base/ftwinfnt.c",
        "src/bdf/bdf.c",
        "src/bzip2/ftbzip2.c",
        "src/cache/ftcache.c",
        "src/cff/cff.c",
        "src/cid/type1cid.c",
        "src/gzip/ftgzip.c",
        "src/lzw/ftlzw.c",
        "src/pcf/pcf.c",
        "src/pfr/pfr.c",
        "src/psaux/psaux.c",
        "src/pshinter/pshinter.c",
        "src/psnames/psnames.c",
        "src/raster/raster.c",
        "src/sdf/sdf.c",
        "src/sfnt/sfnt.c",
        "src/smooth/smooth.c",
        "src/svg/svg.c",
        "src/truetype/truetype.c",
        "src/type1/type1.c",
        "src/type42/type42.c",
        "src/winfonts/winfnt.c",
    };

    const FreeType_Flags = &[_][]const u8 {
        "-std=c99",
    };

    lib.defineCMacro("FT2_BUILD_LIBRARY", "1");
    // if (options.use_system_zlib) {
    //     lib.defineCMacro("FT_CONFIG_OPTION_SYSTEM_ZLIB", "1");
    // }

    // if (options.brotli)
    //     lib.defineCMacro("FT_REQUIRE_BROTLI", "1");

    const target_info = (std.zig.system.NativeTargetInfo.detect(target) catch unreachable).target;

    if (target_info.os.tag == .windows) {
        lib.addCSourceFile("builds/windows/ftsystem.c", FreeType_Flags);
        lib.addCSourceFile("builds/windows/ftdebug.c", FreeType_Flags);
    } else {
        lib.addCSourceFile("src/base/ftsystem.c", FreeType_Flags);
        lib.addCSourceFile("src/base/ftdebug.c", FreeType_Flags);
    }

    if (target_info.os.tag.isBSD() or target_info.os.tag == .linux) {
        lib.defineCMacro("HAVE_UNISTD_H", "1");
        lib.defineCMacro("HAVE_FCNTL_H", "1");
        lib.addCSourceFile("builds/unix/ftsystem.c", FreeType_Flags);
        if (target_info.os.tag == .macos)
            lib.addCSourceFile("src/base/ftmac.c", FreeType_Flags);
    }

    lib.addCSourceFiles(FreeType_Sources, FreeType_Flags);

    lib.installHeadersDirectory("include", ".");
    b.installArtifact(lib);
}
