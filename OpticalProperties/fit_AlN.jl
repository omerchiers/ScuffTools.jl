using LsqFit, DataFrames, RadiativeHeat, Cubature
using Plots

const c0 = 299792458 #m / s

abstract FileType
abstract Material <: FileType

immutable AlN <: Material end

function import_data(filetype :: Material, filename:: String)

    df = DataFrame()
    df = readtable(filename, header=false, separator=' ')

    nrows = size(df, 1)
    ncols = size(df, 2)

    wl    = zeros(Float64,nrows)
    n     = zeros(Float64,nrows)
    k     = zeros(Float64,nrows)

    colnames    = [:x1 , :x2, :x3]
    newcolnames = [:Wavelength , :n, :k]

    for i = 1:nrows
        wl[i] = df[i,1]
        n[i]  = df[i,2]
        k[i]  = df[i,3]
    end

    return wl, n .+ im.*k
end

function lorentz(w,p)
   w = ħ/(1.6021766e-19)*w
   return  p[1] + p[2]^2/(p[3]^2 - w^2 - im*w*p[4])
 end

 lorentz_ri(w,p) = sqrt(lorentz(w,p))

 function lorentz_ri(w::Array{Float64},p)
     dim = div(length(w),2)
     gr = real.(lorentz_ri.(w[1:dim],[p]))
     gi = imag.(lorentz_ri.(w[1:dim],[p]))
     return [gr ; gi]
 end



 function gaussian_lorentz(w,x,p)
     w = ħ/(1.6021766e-19)*w
     return 1.0/sqrt(2.0*pi*p[1]^2)*exp(-(x-p[2])^2/2.0/p[1]^2)*p[3]^2/(x^2 -w^2-im*p[4]*w)
 end

function gaussian_lorentz_ri(w,p)
    f(x) = gaussian_lorentz(w,x,p)
    f2r(u) = real(f(u/(1-u^2))*(1.0+u^2)/(1.0-u^2)^2)
    f2i(u) = imag(f(u/(1-u^2))*(1.0+u^2)/(1.0-u^2)^2)

    fr(x) = real(f(x))
    fi(x) = imag(f(x))


    val1 = 0.0 :: Float64
    err1 = 0.0 :: Float64
    val2 = 0.0 :: Float64
    err2 = 0.0 :: Float64


    (val1,err1) = hquadrature(fr, -1.0, 1.0; reltol=1e-8, abstol=0, maxevals=0)
    (val2,err2) = hquadrature(fi, -1.0, 1.0; reltol=1e-8, abstol=0, maxevals=0)

    eps = p[5] + val1+ im*val2

    return sqrt(eps)
end

function gaussian_lorentz_ri(w::Array{Float64},p)

    dim = div(length(w),2)
    gr = real.(gaussian_lorentz_ri.(w[1:dim],[p]))
    gi = imag.(gaussian_lorentz_ri.(w[1:dim],[p]))

    return [gr ; gi]

end


function fit_data(model :: Function, wl,refrind, p0 )
    w = 2.0*pi*c0./(wl*1e-6)
    xdata = [w ; w]
    ydata = [real(refrind) ; imag(refrind)]
    fit = curve_fit(model, xdata, ydata,p0)
    return fit
end

function plot_material(filetype :: Material, filename :: String,model :: Function , param)

    wl, refind = import_data(filetype, filename)
    ri         = model([wl;wl],param)
    dim        = div(length(ri),2)

    scatter(wl,real(refind))
    scatter!(wl,imag(refind))
    plot!(wl,ri[1:dim])
    plot!(wl,ri[dim+1: end])

end

function main(model :: Function,p)
    dirname  = "/home/omerchiers/Documents/Travail/02-Recherche/Travaux/Projets_en_cours/Near_Field_Radiative_Heat_Transfer/06-Cylindres_Ilari/data/Optical_properties/"
    filename = "AlN_wl_microns_n_k.dat"
    file     = dirname*filename
    wl,ri    = import_data(AlN(), file)
    fit      = fit_data(model, wl,ri,p)
    println(fit.param)
    plot_material(AlN(),file,model,fit.param)
end

function main_plot(model :: Function, p)
    dirname  = "/home/omerchiers/Documents/Travail/02-Recherche/Travaux/Projets_en_cours/Near_Field_Radiative_Heat_Transfer/06-Cylindres_Ilari/data/Optical_properties/"
    filename = "AlN_wl_microns_n_k.dat"
    file     = dirname*filename
    wl,ri    = import_data(AlN(), file)
    plot_material(AlN(),file,model,p)
end
