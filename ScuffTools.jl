
using Plots; pyplot()
using DataFrames, MultiLayerNFRHT, StatPlots


# constants
const w0 = 3.0e14

# Types
export FileType, SIFlux
export import_data, plot_scuff

# Files
include("plot/plotting.jl")
include("plot/importing.jl")
include("run/run_on_cluster.jl")
include("utils/utils.jl")
