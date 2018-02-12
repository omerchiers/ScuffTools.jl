
#using Plots; pyplot()
using DataFrames, MultiLayerNFRHT, StatPlots


# constants
const w0 = 3.0e14

# Types
export FileType, SIFlux
export import_data,extract_data,
       plot_scuff,benchmark_freq,
       transfer_w,total_transfer,frequency_file,
       scuff_job,scuff_parallel


# Files
include("plot/plotting.jl")
include("plot/importing.jl")
include("run/run_on_cluster.jl")
include("utils/utils.jl")
