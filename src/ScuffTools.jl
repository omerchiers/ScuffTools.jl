module ScuffTools

using Plots; plotly()
using DataFrames
using MultiLayerNFRHT


# constants
const w0 = 3.0e14

abstract type FileType end
struct SIFlux       <: FileType end
struct TotalFlux{T} <: FileType end

# export of functions
export FileType,SIFlux,TotalFlux,
       import_data,simulation_data,
       plot_scuff,benchmark_freq,
       scuff_job,scuff_parallel,
       transfer_w,total_transfer,frequency_file


# Files
include("plotting.jl")
include("importing.jl")
include("run_on_cluster.jl")
include("utils.jl")

end #module
