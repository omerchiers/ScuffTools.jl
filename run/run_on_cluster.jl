

#=
function serial_job(args...)
    cmd = ""
    for (i,arg) in enumerate(args)
       cmd *= " "*arg
    end
    run(`scuff-neq $cmd`)
end
=#

"""
    scuff_job(frequency :: Float64, geometry_file :: String ,  output_file :: String )

Serial job for a single frequency given as a float
# Arguments
- `frequency :: Float64` : frequency in radHz. Note that to get the real frequncies, one has to multiply by 3e14.
- `geometry_file :: String` : the *.scuffgeo file
- `output_file :: String` : string to be added to the *.EMTPFT file
"""
function scuff_job(frequency :: Float64, geometry_file :: String ,  output_file :: String )
    freq = string(frequency)
    output = output_file*"freq="*freq*"_radHz"
    run(`scuff-neq --Geometry $geometry_file --Omega $frequency --EMTPFT --FileBase $output`)
end


"""
    scuff_job(frequency :: String, geometry_file :: String ,  output_file :: String )

when using a file containing one or many frequencies
# Arguments
- `frequency :: String` : the name of the file containing the frequencies.
"""
function scuff_job(frequencyfile :: String, geometry_file :: String ,  output_file :: String )
    lines  = readlines(frequencyfile)
    output = output_file*"freq="*lines[1]*"-"*lines[end]
    run(`scuff-neq --Geometry $geometry_file --OmegaFile $frequencyfile --EMTPFT --FileBase $output`)
end


"""
    scuff_parallel(frequencies, geometry_file :: String ,  output_file :: String )

Launch parallel computation for a range of frequencies
# Arguments
- `frequencies` : range object for the frequencies.

# Examples

```jldoctest
julia> frequencies = 1e2:1e2:1e3
100.0:100.0:1000.0
julia> frequencies = linspace(1e2,1e3,10)
100.0:100.0:1000.0
julia> frequencies = logspace(2,3,10)
10-element Array{Float64,1}:
  100.0
  129.155
  166.81
  215.443
  278.256
  359.381
  464.159
  599.484
  774.264
 1000.0
```
"""
function scuff_parallel(frequencies :: AbstractArray, geometry_file :: String , output_file :: String)
    freqv = collect(frequencies)
    scuff_par(frequency) = scuff_job(frequency, geometry_file, output_file)
    pmap(scuff_par, freqv)
end

"""
    scuff_parallel(frequencies :: AbstractString , geometry_file :: AbstractString , output_file :: AbstractString)
when frequencies is a filename, reads the data
"""

function scuff_parallel(frequencies :: AbstractString , geometry_file :: AbstractString , output_file :: AbstractString)
    freqv = readdlm(frequencies)
    scuff_par(frequency) = scuff_job(frequency, geometry_file, output_file)
    pmap(scuff_par, freqv)
end
