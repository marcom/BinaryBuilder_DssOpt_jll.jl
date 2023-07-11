# NOTE: has to be run with julia-1.7 until this bug is finished:
#       https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/1212#issuecomment-1613119134

using BinaryBuilder, Pkg
using BinaryBuilderBase: BuildDependency

name = "DssOpt"
version = v"1.0.5"

# url = "https://github.com/marcom/dss-opt/"
# description = "Dynamics in sequence space optimisation for RNA sequence design"

sources = [
    # v1.0.5 (2023-07-11)
    GitSource("https://github.com/marcom/dss-opt/",
              "3058fb040fdcebf901b250b624f7a9e0670ef96f")

    # Old builds

    # v1.0.4 (2023-07-02)
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "b3fc9ffc7890e621e5003773f3e024ebb07cea84")

    # v1.0.3 (2023-06-27)
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "1b3f7e2a6ab332ad95fb6c3921b71734d8a9df18")

    # v1.0.2 (2023-06-27)
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "752fd8ccf3b6bf24904c17cf82521cf1a3838622")

    # 2023-06-26
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "dc2af7474fe512e1cb783dead584c3ccbb990de5")

    # 2023-03-19
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "23f785736951e7369ae122a4a1c397948daecea1")

    # 2022-12-03 git-sha1: 818cf83319ed85e11c01d00db3eeaedd2ce5815f
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "818cf83319ed85e11c01d00db3eeaedd2ce5815f")

    # v1.0.1 (2022-09-23) git-sha1: cb69a3b9af1befdaad3bae53c764594011418016
    #                     DssOpt-v1.0.1+0 in https://github.com/marcom/DssOpt_jll.jl
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "cb69a3b9af1befdaad3bae53c764594011418016")

    # v1.0 (2012) (release tarballs made on github Sep 22, 2022)
    # GitSource("https://github.com/marcom/dss-opt/",
    #           "c0c1e0f47f5346453a9e73f26ba08a6e826d5a9b")

    #DirectorySource("/home/mcm/src/dss-opt/dss-opt.git/";
    #                target="dss-opt-git"),
]

script = raw"""
cd $WORKSPACE/srcdir/

# remove -Werror, mingw32 doesn't have '%zu' printf format
sed -i -e 's/-Werror//g' Makefile

# build main executables
CPPFLAGS="-I${includedir}" make -j${nproc} CC=${CC} LIB_FILE_EXT=${dlext} all lib

# build rna-ensemble-distance
cd rna-ensemble-distance-with-ViennaRNA
# can't use VIENNA_LIB=$libdir on windows, because there libdir=$prefix/bin
make VIENNA_INC="${includedir}/ViennaRNA" VIENNA_LIB="${prefix}/lib"
cd ..

# install executables
for f in eval-{dGdp,pseq,score,useq} opt-{md,sd,sd-gsl} random-{seq,vienna}; do
    install -Dvm 755 "${f}${exeext}" "${bindir}/"
done

# install rna-ensemble-distance
install -Dvm 755 "rna-ensemble-distance-with-ViennaRNA/rna-ensemble-distance${exeext}" "${bindir}/"

# install lib
install -Dvm 644 libdssopt.${dlext} "${libdir}/"

# install headers
for header in *.h */*.h; do
    install -Dvm 644 "${header}" "${prefix}/include/${header}"
done

cp ${prefix}/share/licenses/ViennaRNA/COPYING COPYING-rna-ensemble-distance
install_license COPYING-rna-ensemble-distance
install_license COPYING
"""

platforms = supported_platforms()

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
    ExecutableProduct("rna-ensemble-distance", :rna_ensemble_distance),
    LibraryProduct("libdssopt", :libdssopt),
]

dependencies = [
    Dependency(PackageSpec(name="GSL_jll")),
    BuildDependency(PackageSpec(name="ViennaRNA_jll", version=v"1.8.5")),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6", preferred_gcc_version = v"9")
