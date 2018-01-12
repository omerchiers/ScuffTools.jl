"""
Scripts for launching jobs on cluster

"""


function scuff_job(frequency :: String, geometry_file :: String ,  output_file :: String )
    output = outputfile*"freq="*frequency*"_radHz"
    run(`scuff-neq --Geometry $geometry_file --Omega $frequency --EMTPFT --FileBase $output`)
end


function scuff_parallel(frequencies, geometry_file :: String , output_file :: String)
    freqv = string.(collect(frequencies))
    scuff_par(frequency) = scuff_job(frequency, geometry_file, output_file)
    pmap(scuff_par, freqv)
end
