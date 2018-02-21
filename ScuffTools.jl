
#using Plots; pyplot()
using DataFrames, MultiLayerNFRHT, StatPlots, Parameters


# constants
const w0 = 3.0e14


# Files
include("plot/plotting.jl")
include("plot/importing.jl")
include("run/run_on_cluster.jl")
include("utils/utils.jl")
