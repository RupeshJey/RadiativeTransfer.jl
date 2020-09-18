
# Eqn. 1 (not averaged)
function compute_C_scatt(k, nmax, an, bn)
    return (2π/k^2) * sum(n->(2n+1)*(abs2(an[n]) + abs2(bn[n])), 1:nmax)
end

# Eqn. 1, averaged over size distribution using for loops 
function compute_avg_C_scatt2(k, ans_bns, w)
    a = 0
    for n=1:size(ans_bns)[2]
        for m=1:size(ans_bns)[3]
            a += (2n+1)* (w[m] * (abs2(ans_bns[1,n,m]) + abs2(ans_bns[2,n,m])))
        end
    end
    return (2π/k^2) * a
end



function compute_avg_anbn!(an, bn, w, Nmax, N_max_, mat_anam, mat_bnbm, mat_anbm, mat_bnam)
    FT2 = eltype(an)
    fill!(mat_anam,0)
    fill!(mat_bnbm,0)
    fill!(mat_anbm,0)
    fill!(mat_bnam,0)
    @inbounds for n=1:Nmax
        @inbounds for m=n:Nmax
            anam = FT2(0);
            bnbm = FT2(0);
            anbm = FT2(0);
            bnam = FT2(0);
            @inbounds for i = 1:size(an,1)
                if m < N_max_[i] && n < N_max_[i]
                    anam += w[i] * an[i,n]' * an[i,m]
                    bnbm += w[i] * bn[i,n]' * bn[i,m]
                    anbm += w[i] * an[i,n]' * bn[i,m]
                    bnam += w[i] * bn[i,n]' * an[i,m]
                end
            end 
            @inbounds mat_anam[m,n] = anam;
            @inbounds mat_bnbm[m,n] = bnbm;
            @inbounds mat_anbm[m,n] = anbm;
            @inbounds mat_bnam[m,n] = bnam;
        end
    end
    return nothing
end



# wₓC = CuArray(wₓ)
# N_max_C = CuArray(N_max_)
# FT2 = Complex{Float64}
# mat_anam = LowerTriangular(zeros(FT2,Nmax,Nmax));
# mat_bnbm = LowerTriangular(zeros(FT2,Nmax,Nmax));
# mat_anbm = LowerTriangular(zeros(FT2,Nmax,Nmax));
# mat_bnam = LowerTriangular(zeros(FT2,Nmax,Nmax));

# an, bn = compute_abns(aero, wl, r);

# anC = CuArray(an)
# bnC = CuArray(bn)
# mat_anamC = CuArray(mat_anam)
# mat_bnbmC = CuArray(mat_bnbm)
# mat_bnamC = CuArray(mat_bnam)
# mat_anbmC = CuArray(mat_anbm)

# @time goCPU()