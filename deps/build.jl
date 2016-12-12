using BinDeps

@BinDeps.setup

libmongoc = library_dependency(
    "libmongoc",
    aliases = ["libmongoc", "libmongoc-1.0"]
    )

provides(Sources, Dict(
    URI("http://github.com/mongodb/mongo-c-driver/releases/download/1.0.0/mongo-c-driver-1.0.0.tar.gz") => libmongoc
    ))

provides(
    BuildProcess,
    Autotools(libtarget = "libmongoc-1.0.la"),
    libmongoc,
    os = :Unix
    )
            
@osx_only begin
    using Homebrew
    provides(Homebrew.HB, Dict("mongo-c-driver" => libmongoc))
end

@BinDeps.install Dict(:libmongoc => :libmongoc)
