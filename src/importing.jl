

"""
    import_data(filename:: String ; transf = "DEFAULT")

extracts the desired data from a file *.EMTPFT.
# Arguments
- `transf = "DEFAULT"` : is the label for the transformation if Only 1 configuration was computed.
"""
function import_data(filename:: String ; transf = "DEFAULT")
    df            = DataFrame(readdlm(filename,' ')) # this line will have to be modified with DataFrames 0.11
    dfPabs,dfPrad = extract_data( df , transf)
    return dfPabs,dfPrad
end


"""
    import_data(filename:: Vector{String} ; transf = "DEFAULT")

puts everything in a single dataframe if given a list of files.
# Arguments
- `transf = "DEFAULT"` : is the label for the transformation if Only 1 configuration was computed.
"""
function import_data(filename:: Vector{String} ; transf = "DEFAULT")
    dfPabsv = DataFrame[]
    dfPradv = DataFrame[]
    for i = 1:length(filename)
        dfPabs_temp, dfPrad_temp = import_data(filename[i] ; transf=transf)
        dfPabsv = push!(dfPabsv,dfPabs_temp)
        dfPradv = push!(dfPradv,dfPrad_temp)
    end
    dfPabs = extract_data(dfPabsv , transf)
    dfPrad = extract_data(dfPradv , transf)
    return dfPabs,dfPrad
end

function extract_data(df :: DataFrame , transf)
    df1 = df[df[:x1] .== transf, :]
    nrows = size(df1, 1)
    ncols = size(df1, 2)

    Pabs  = zeros(Float64,Int(nrows/4),5)
    Prad  = zeros(Float64,Int(nrows/4),5)

    colnames    = [:x1 , :x2, :x3, :x4, :x5]
    newcolnames = [:Freq , :c11, :c12, :c21 ,:c22]

    count = 1
    for i = 1:4:nrows
        Pabs[count,1] = df1[i,2]
        Prad[count,1] = df1[i,2]
        for j=0:3
            Pabs[count,j+2]   = df1[i+j,4]
            Prad[count,j+2]   = df1[i+j,5]
        end
        count +=1
    end
    dfPabs = DataFrame(Pabs)
    dfPrad = DataFrame(Prad)

    rename!(dfPabs,colnames,newcolnames)
    rename!(dfPrad,colnames,newcolnames)

    return dfPabs, dfPrad
end


function extract_data(df :: Vector{DataFrame} , transf)
    df_temp = df[1]
    for i =2:length(df)
        append!(df_temp,df[i])
    end
    sort!(df_temp, cols = :Freq)
    return df_temp
end

function convert_to_array(dfPabs,dfPrad,columnname)
    dfPabs[:Freq] = w0.*dfPabs[:Freq]
    dfPrad[:Freq] = w0.*dfPrad[:Freq]
    wv   = dfPabs[:Freq]
    Prad = dfPrad[:,columnname]
    Pabs = dfPabs[:,columnname]
    return wv, Pabs, Prad
end

function write_data(flname,dict)
   for k in keys(dict)
        propname = k
        writetable(flname*"_"*propname*".dat", dict[k])
    end
end

"""
    simulation_data(filetype :: SIFlux,...)

Return and save (optional) the spectral flux and transfer function.

# Arguments
- `trans = "DEFAULT"` : the number of the transformation, trans = "DEFAULT" if no transformation is given
- `filename ::  Union{String,Vector{String}}` : can be single filename or an array of filenames for parallel computations
- `columnname` : column name. Example : [:c12]. Only use one name at the time.
"""
function simulation_data(filetype :: SIFlux, filename :: Union{String,Vector{String}}, columnname ,T1,T2, trans = "DEFAULT"; savefile = (false," "))
    dfPabs,dfPrad  = import_data(filename ; transf = transf)
    wv, Pabs, Prad = convert_to_array(dfPabs,dfPrad,columnname)

    qtrans = zeros(Float64,length(wv))
    qtrans = transfer_w.(T1,T2,wv,Prad)
    Qtrans = [wv qtrans]

    if savefile[1] == true
        dfQtrans = DataFrame(Qtrans)
        dc = Dict("Prad" => dfPrad ,"Pabs" => dfPabs , "Qtrans" => dfQtrans)
        write_data(savefile[2], dc)
    end
    return wv, Pabs, Prad, qtrans
end


"""
    simulation_data(filetype :: TotalFlux{:vsT},...)

Return and save (optional) total heat_transfer as a function temparature of one of the bodies and transfer function.
# Arguments
- `Tmin` : minimum value of temperature of body 2
- `Tmax` : maximum value of temperature of body 2
- `T1 = 0.0` : temperature of body 1. Set by default at 0.0K
"""
function simulation_data(filetype :: TotalFlux{:vsT}, filename:: Union{String,Vector{String}}, columnname,Tmin,Tmax, trans= "DEFAULT";T1=0.0, savefile = (false," "))
    dfPabs,dfPrad  = import_data(filename ; transf = transf)
    wv, Pabs, Prad = convert_to_array(dfPabs,dfPrad,columnname)

    Tempv = collect(linspace(Tmin,Tmax,100))
    q_tot = zeros(Float64,100)
    tt(T) = total_transfer(T1,T,wv,Prad)
    q_tot = tt.(Tempv)
    Qtrans = [Tempv q_tot]

    if savefile[1] == true
        dfQtrans = DataFrame(Qtrans)
        dc = Dict("Prad" => dfPrad ,"Pabs" => dfPabs , "Qtrans_vs_T_" => dfQtrans)
        write_data(savefile[2], dc)
    end
    return wv, Pabs, Prad, Tempv, Qtrans
end


"""
    simulation_data(filetype :: TotalFlux{:vsd},...)

Return and save (optional) total heat_transfer as a function separation distance and transfer function for each separation distance.
# Arguments
- `T1` : Temperature of body 1
- `T2` : Temperature of body 2
- `trans` : vector containing the transformation label
"""
function simulation_data(filetype :: TotalFlux{:vsd}, filename :: Union{String,Vector{String}}, columnname ,T1,T2, trans; savefile = (false," "))
    q_tot   = zeros(Float64,length(collect(trans)))

    for i in trans
        dfPabs,dfPrad  = import_data(filename ; transf = Float64(trans[i]))
        wv, Pabs, Prad = convert_to_array(dfPabs,dfPrad,columnname)
        q_tot[i]       = total_transfer(T1,T2,wv,Prad)
        if savefile[1] == true
            dc = Dict("Prad_trans="*"_$i" => dfPrad ,"Pabs_trans="*"_$i" => dfPabs)
            write_data(savefile[2], dc)
        end
    end

    Qtrans = [trans q_tot]
    if savefile[1] == true
        dfQtrans = DataFrame(Qtrans)
        dc = Dict("Qtrans_vs_dist_" => dfQtrans)
        write_data(savefile[2], dc)
    end
    return trans, q_tot
end


"""
    simulation_data(filetype :: TotalFlux{:vsth},...)

Return and save (optional) total heat_transfer as a function cylinder thickness.
# Arguments
- `T1` : temperature of body 1
- `T2` : temperature of body 2
"""
function simulation_data(filetype :: TotalFlux{:vsth}, filename:: Vector{String}, columnname,T1,T2, trans= "DEFAULT"; savefile = (false," "))

    lengthlist = length(filename)
    q_tot      = zeros(Float64,lengthlist)
    thv        = zeros(Float64,lengthlist)

    for i in 1:lengthlist
        dfPabs,dfPrad  = import_data(filename[i] ; transf = trans)
        wv, Pabs, Prad = convert_to_array(dfPabs,dfPrad,columnname)
        q_tot[i]       = total_transfer(T1,T2,wv,Prad)
        indexb         = searchindex(filename[i],"=")
        indexe         = searchindex(filename[i],"microns")
        thv[i]         = parse(Float64,filename[i][indexb+1:indexe-1])

        if savefile[1] == true
            dc = Dict("Prad_th="*"_$i" => dfPrad ,"Pabs_th="*"_$i" => dfPabs)
            write_data(savefile[2], dc)
        end

    end

    Qtrans = [thv q_tot]

    if savefile[1] == true
        dfQtrans = DataFrame(Qtrans)
        dc = Dict("Prad" => dfPrad ,"Pabs" => dfPabs , "Qtrans_vs_th_" => dfQtrans)
        write_data(savefile[2], dc)
    end
    return thv, q_tot
end
