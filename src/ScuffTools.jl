module ScuffTools

using Plots
using DataFrames
using MultiLayerNFRHT


# constants
const w0 = 3.0e14

# export of functions
export import_data,simulation_data,
       plot_scuff,benchmark_freq,
       scuff_job,scuff_parallel,
       transfer_w,total_transfer,frequency_file


# Files
include("plot/plotting.jl")
include("plot/importing.jl")
include("run/run_on_cluster.jl")
include("utils/utils.jl")

end #module
