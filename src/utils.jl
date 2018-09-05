
#Uitlity functions

" Spectral heat flux "
function transfer_w(T1,T2,w,τ)
    return (bose_einstein(w,T1)-bose_einstein(w,T2))*τ
end


"Total heat flux obtained from simulation"
function total_transfer(T1,T2,w,τ)
  t_w   = transfer_w.(T1,T2,w,τ)
  q_tot = trapz(w,t_w)
  return q_tot
end

"Generates frequency file that serves as imput to scuff-em"
function frequency_file(freqnum,T,typespace :: String ; f1=0.01 ,f2=10.0)
    freq = zeros(Float64,freqnum)
    if typespace == "linspace"
        freq =collect(linspace(f1*wien(T)/w0,f2*wien(T)/w0,freqnum))
        dffreq = DataFrame(Freq=freq)
        writetable("frequency_N="*string(freqnum)*"_"*typespace*".dat", dffreq,header=false)
    elseif typespace == "logspace"
        wi = log10(f1*wien(T)/w0)
        wf = log10(f2*wien(T)/w0)
        freq =collect(logspace(wi,wf,freqnum))
        dffreq = DataFrame(Freq=freq)
        writetable("frequency_N="*string(freqnum)*"_"*typespace*".dat", dffreq,header=false)
    end
end


"Computes the view factor between 2 parallel finite plates"
function view_factor(w,l,distance)
    x = w/distance
    y = w/distance
    return 2/(pi*x*y)*(log(sqrt((1 + x^2)*(1 + y^2)/(1 + x^2 + y^2)))
                          + x*sqrt(1 + y^2)*atan(x/sqrt(1 + y^2))
                          + y*sqrt(1 + x^2)*atan(y/sqrt(1 + x^2))
                          - x*atan(x) - y*atan(y))
end
