

"""
Import the data from a file *.SIFlux. transf is the label for the transformation. If Only 1 configuration was computed,
then transf=DEFAULT

"""

function import_data(filetype :: SIFlux, filename:: String ; transf = "DEFAULT")

    df = DataFrame(readdlm(filename,' ')) # this line will have to be modified with DataFrames 0.11

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


    return dfPabs,dfPrad
end

"""
Import data from parallel calculation.
If you are in the directory containing the files, just give the

"""

function import_data(filetype :: SIFlux{:parallel}, dirname :: String ; transf = "DEFAULT")
    files = readdir(dirname)
    dfPabs,dfPrad = import_files(SIFlux(), files ; trans = transf)
    return dfPabs,dfPrad
end


function import_files(filetype :: FileType , filenames :: Union{String,Vector{String}} ; transf = "DEFAULT")
    if typeof(filenames) == String
        dfPabs, dfPrad = import_data(filetype, filenames ; trans = transf )
        return dfPabs,dfPrad
    elseif typeof(filenames) == Vector{String}
        for i = 1:length(filenames)
            dfPabsi, dfPradi = import_data(filetype, filenames[i] ; trans = transf )
            dfPabs = append!(dfPabs,dfPabsi)
            dfPrad = append!(dfPrad,dfPradi)
        end
        return dfPabs,dfPrad
    end
end
