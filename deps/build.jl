using BinDeps
@BinDeps.setup

libbnet = library_dependency("libbnet")

libdir = BinDeps.libdir(libbnet)
srcdir = BinDeps.srcdir(libbnet)
downloadsdir = BinDeps.downloadsdir(libbnet)

prefix=joinpath(BinDeps.depsdir(libbnet),"usr")
uprefix = replace(replace(prefix,"\\","/"),"C:/","/c/")
bnetsrcdir = joinpath(BinDeps.depsdir(libbnet),"src","binary_networks")
provides(Sources,URI("https://raw.githubusercontent.com/afternone/CommunityDetection.jl/master/deps/binary_networks.tar.gz"), libbnet)
provides(BuildProcess,
    (@build_steps begin
        GetSources(libbnet)
        CreateDirectory(libdir)
        @build_steps begin
            ChangeDirectory(bnetsrcdir)
            FileRule(joinpath(prefix,"lib","libbnet.so"),@build_steps begin
                `make`
                `cp libbnet.so $libdir`
            end)
        end
    end),libbnet)

@BinDeps.install Dict(:libbnet => :libbnet)
