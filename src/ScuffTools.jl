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
include("plotting.jl")
include("importing.jl")
include("run_on_cluster.jl")
include("utils.jl")

end #module
