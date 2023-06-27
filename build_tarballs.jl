using BinaryBuilder, Pkg

name = "DssOpt"
version = v"1.0.1"

# url = "https://github.com/marcom/dss-opt/"
# description = ""

sources = [
    # # v1.0 (2012) (release tarballs made on github Sep 22, 2022)
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "c0c1e0f47f5346453a9e73f26ba08a6e826d5a9b")

    # # v1.0.1 (2022-09-23) git-sha1: cb69a3b9af1befdaad3bae53c764594011418016
    # #                     DssOpt-v1.0.1+0 in https://github.com/marcom/DssOpt_jll.jl
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "cb69a3b9af1befdaad3bae53c764594011418016")

    # # 2022-12-03 git-sha1: 818cf83319ed85e11c01d00db3eeaedd2ce5815f
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "818cf83319ed85e11c01d00db3eeaedd2ce5815f")

    # 2023-03-19
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "23f785736951e7369ae122a4a1c397948daecea1")

    # 2023-06-26
    GitSource("https://github.com/marcom/dss-opt/",
              "dc2af7474fe512e1cb783dead584c3ccbb990de5")

    #DirectorySource("/home/mcm/src/dss-opt/dss-opt.git/";
    #                target="dss-opt-git"),
]

script = raw"""
cd $WORKSPACE/srcdir/

CPPFLAGS="-I${includedir}" make -j${nproc} CC=${CC} LIB_FILE_EXT=${dlext} all lib

# install executables
for f in eval-{dGdp,pseq,score,useq} opt-{md,sd,sd-gsl} random-{seq,vienna}; do
    install -Dvm 755 "${f}${exeext}" "${bindir}/"
done

# install lib
install -Dvm 644 libdssopt.${dlext} "${libdir}/"

# install headers
for header in *.h */*.h; do
    install -Dvm 644 "${header}" "${prefix}/include/${header}"
done

install_license COPYING
"""

platforms = supported_platforms()
platforms = expand_cxxstring_abis(platforms)

products = [
    ExecutableProduct("eval-dGdp", :eval_dGdp),
    ExecutableProduct("eval-pseq", :eval_pseq),
    ExecutableProduct("eval-score", :eval_score),
    ExecutableProduct("eval-useq", :eval_useq),
    ExecutableProduct("opt-md", :opt_md),
    ExecutableProduct("opt-sd", :opt_sd),
    ExecutableProduct("opt-sd-gsl", :opt_sd_gsl),
    ExecutableProduct("random-seq", :random_seq),
    ExecutableProduct("random-vienna", :random_vienna),
    LibraryProduct("libdssopt", :libdssopt),
]

dependencies = [
    Dependency(PackageSpec(name="GSL_jll")),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6", preferred_gcc_version = v"9")
