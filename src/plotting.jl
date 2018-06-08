# File with plotting routines

# constants
const w0 = 3.0e14


abstract type FileType end
struct SIFlux       <: FileType end
struct TotalFlux{T} <: FileType
    parameter      :: T
    range          :: Tuple{Float64,Float64}
    filename       :: Union{String,Vector{String}}
    columname      :: Array{Symbol,1}
    temperatures   :: Tuple{Float64,Float64}
    transformation 
end


"""
    plot_scuff(filetype :: SIFlux,...)

Plot and save (optional) the spectral flux and transfer function.

# Arguments
- `trans` : the number of the transformation, trans = "DEFAULT" if no transformation is given
- `filename ::  Union{String,Vector{String}}` : can be single filename or an array of filenames for parallel computations
- `columnname` : column name. Example : [:c12]. Only use one name at the time.
"""
function plot_scuff(filetype :: SIFlux, filename :: Union{String,Vector{String}}, columnname :: Array{Symbol,1} ,T1,T2, trans = "DEFAULT"; savefile = (false," "))

    wv, Pabs, Prad, qtrans = simulation_data(filetype, filename , columnname ,T1,T2, trans = trans; savefile = savefile)

    p1 = plot(wv, abs.(Prad),
              xscale = :log10,
              xlim = (wv[1],wv[end]),
              yscale = :log10,
              title = "Prad",
              xlabel = "Frequency (rad/s)",
              ylabel= "Transfer function")
    p2 = plot(wv, abs.(Pabs),
              xscale = :log10,
              xlim = (wv[1],wv[end]),
              yscale = :log10,
              title = "Pabs",
              xlabel = "Frequency (rad/s)",
              ylabel= "Transfer function")
    p3 = plot(wv, abs.(qtrans) ,
              xscale = :log10,
              yscale = :log10,
              title = "Ptransf",
              xlabel ="Frequency (rad/s)" ,
              ylabel= "heat transfer")
    l = @layout [p1 p2; p3]
    plot(p1,p2,p3,layout = l)

end


"""
    plot_scuff(filetype :: TotalFlux{:vsT},...)

Compute and plot total heat_transfer as a function temparature of one of the bodies.
# Arguments
- `Tmin` : minimum value of temperature of body 2
- `Tmax` : maximum value of temperature of body 2
- `T1 = 0.0` : temperature of body 1. Set by default at 0.0K
"""
function plot_scuff(filetype :: TotalFlux{:vsT}, filename:: Union{String,Vector{String}}, columnname :: Array{Symbol,1},Tmin,Tmax, trans= "DEFAULT";T1=0.0, savefile = (false," "))

    wv, Pabs, Prad, Tempv, q_tot = simulation_data(filetype, filename, columnname ,Tmin,Tmax, trans= trans;T1=T1, savefile = savefile)

    p1 = plot(wv, abs.(Prad),
              xscale = :log10,
              xlim = (wv[1],wv[end]),
              yscale = :log10, #ylim = (1e-30,1e-10),
              title = "Prad",
              xlabel = "Frequency (rad/s)",
              ylabel= "Transfer function")
    p2 = plot(Tempv, abs.(q_tot),
              yscale = :log10,
              title = "Qtransf",
              xlabel ="Temperature (K)" ,
              ylabel= "Total flux (W)")
    l = @layout [p1 p2]
    plot(p1,p2,layout = l)

end

"""
    plot_scuff(filetype :: TotalFlux{:vsd},...)

Computes total heat_transfer as a function separation distance.
# Arguments
- `T1` : Temperature of body 1
- `T2` : Temperature of body 2
- `trans` : vector containing the transformation label
"""
function plot_scuff(filetype :: TotalFlux{:vsd}, filename :: Union{String,Vector{String}}, columnname :: Array{Symbol,1} ,T1,T2, trans; savefile = (false," "))

trans, q_tot = simulation_data(filetype, filename, columnname ,T1,T2, trans; savefile = savefile)

    plot(trans, abs.(q_tot),
         yscale = :log10, #ylim = (1e-,1e-5),
         title = "Prad vs separation distance",
         xlabel = "separation distance",
         ylabel= "Total flux (W)")

end


"""
    plot_scuff(filetype :: TotalFlux{:vsth},...)

Computes total heat_transfer as a function cylinder thickness.
# Arguments
- `T1` : Temperature of body 1
- `T2` : Temperature of body 2
- `trans` : vector containing the transformation label
"""
function plot_scuff(filetype :: TotalFlux{:vsth}, filename :: Union{String,Vector{String}}, columnname :: Array{Symbol,1} ,T1,T2, trans; savefile = (false," "))

trans, q_tot = simulation_data(filetype, filename, columnname ,T1,T2, trans; savefile = savefile)

    plot(trans, abs.(q_tot),
         yscale = :log10, #ylim = (1e-,1e-5),
         title = "Prad vs cylinder thickness",
         xlabel = "separation distance",
         ylabel= "Total flux (W)")

end



"Checks the convergence for the number of frequencies and type by coputing the total flux"

function benchmark_freq(filetype :: SIFlux, dirname :: Union{String,Vector{String}} , filename:: String, columnname :: Array{Symbol,1} ;T1=1.0,T2=0.0, savefile = (false," "))
    discrtype = ["logspace" "linspace"]
    discrnum  = ["N=50" ;"N=100"; "N=150" ;"N=200";"N=500" ; "N=1000" ]
    cnt2 = 0
    q_tot = zeros(Float64,length(discrnum),length(discrtype))
    for dt in discrtype
        cnt2 = cnt2 + 1
        cnt1 = 0
        for dn in discrnum
            cnt1 = cnt1 + 1
            flename = dirname*"/"*dt*"/"*dn*"/"*filename
            dfPabs,dfPrad = import_data(filetype, flename)
            u = dfPabs[:Freq]
            τ = dfPrad[columnname...]
            q_tot[cnt1,cnt2] = total_transfer(T1,T2,u.*w0,τ)
         end
    end

    if savefile[1] == true
        dfqtot = convert(DataFrame,q_tot)
        writetable("Qtot_vs_freqNum_"*savefile[2]*".dat", dfqtot)
    end

    rel_error = abs(q_tot[:,1].-q_tot[:,2])./(-q_tot[:,1]).*100
    p1 = plot([50;100;150;200;500;1000],-q_tot,yaxis = :log10)
    p2 = plot([50;100;150;200;500;1000],rel_error)
    l = @layout [p1 p2]
    plot(p1,p2, layout = l)

end
