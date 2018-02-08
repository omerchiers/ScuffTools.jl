

"""
extracts the desired data from a file *.SIFlux.
# Arguments
- `transf = "DEFAULT"` : is the label for the transformation if Only 1 configuration was computed.

"""

function import_data(filename:: String ; transf = "DEFAULT")
    df            = DataFrame(readdlm(filename,' ')) # this line will have to be modified with DataFrames 0.11
    dfPabs,dfPrad = extract_data( df , transf)
    return dfPabs,dfPrad
end

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
