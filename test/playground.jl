# using Plots
# using PyCall
# using TimerOutputs
# using Statistics
#
# # const to = TimerOutput();
#
# # ht = readHITRAN("/net/fluo/data1/projects/RTM/Mie/hitran/par/02_hit04.par", 2, 1, 6000, 6400)

# using RadiativeTransfer
# include("/home/rjeyaram/RadiativeTransfer/src/RadiativeTransfer.jl")
# using Revise
# using RadiativeTransfer.CrossSection

# # using Test

# # ht = CrossSection.read_hitran("/home/rjeyaram/RadiativeTransfer/test/CO2.data", 2, 1, 6000, 6400)
# ht = CrossSection.read_hitran("/net/fluo/data1/projects/RTM/Mie/hitran/par/02_hit04.par", mol=2, iso=1, ν_min=6000, ν_max=6400)
# modCEF = ErfcHumliErrorFunctionVoigt();
# grid = collect(6000:0.01:6400);

# # @time cs = line_shape(voigt,modCEF,ht,grid,false,1013.0,296,10,0)

# # display(plot(grid, cs, ylims=(0, 3e-17)))

# # @time cs = line_shape(voigt,modCEF,ht,grid,false,1013.15,293,40,0)

# # @time plot(grid, line_shape(doppler,modCEF,ht,grid,false,1013.15,293,40,0), ylims=(0,1e-22))
# # @time plot!(grid, line_shape(lorentz,modCEF,ht,grid,false,1013.15,293,40,0), ylims=(0,1e-22))
# # @time display(plot!(grid, line_shape(voigt,modCEF,ht,grid,false,1013.15,293,40,0), ylims=(0,1e-22)))

# # @time doppler_shift = line_shape(doppler,modCEF,ht,grid,false,1013.15,293,40,0)
# # @time lorentz_shift = line_shape(lorentz,modCEF,ht,grid,false,1013.15,293,40,0)

# # voigt_times = []
# #
# # append!(voigt_times, 1)
# #
# # for i in 1:100
# #     # append!(voigt_times, 1)
# #     time = @elapsed res = line_shape(voigt,modCEF,ht,grid,false,1013.15,293,40,0)
# #     append!(voigt_times, time)
# #     println(time)
# # end
# #
# # println("Mean and stddev")
# # println(mean(voigt_times))
# # println(std(voigt_times))
# #
# # # time = @elapsed res = line_shape(voigt,modCEF,ht,grid,false,1013.15,293,40,0)
# #
# using DelimitedFiles

# CEF = ErfcHumliErrorFunctionVoigt()
# @time cs = absorption_cross_section(Voigt(CEF),ht,grid,false,1013.25,296.0,40,vmr=0)

# using Plots

# maximum(cs)
# plot(grid, cs, ylims=(0, 8e-23))
# plot!(grid, cs, ylims=(0, 8e-23))

# plot

# using Interpolations

# T = 200:10:380;
# p = 1:25:1050;

# cs_matrix = zeros(length(T), length(p), length(grid));

# for iP in eachindex(p)
#     println("iP: ", iP)
#     for iT in eachindex(T)
#         println("iT: ", iT)
#        cs_matrix[iT,iP,:] = line_shape(voigt,modCEF,ht,grid,false,p[iP],T[iT],10.0,0.0);
#     end
#     # println(iP)
# end
# itp = interpolate( cs_matrix, BSpline(Cubic(Line(OnGrid()))))
# sitp = scale(itp,T,p,6000:0.01:6400)


# plot(grid, )

# using Interact

# writedlm( "/home/rjeyaram/RadiativeTransfer/test/voigt_test_julia.csv",  cs, ',')

# using Plots

# b = @manipulate for curr_T = 200:10:380, curr_P = 1:25:1050

#     display(plot(grid, sitp(curr_T, curr_P, grid), ylims=(0, 8e-23)))

# end

# using JLD2
# @save "/home/rjeyaram/RadiativeTransfer/test/savedInterpolation.jld" itp



# function app(req)

#     grid= -10:1:10

#     a = @manipulate for m = 0.1:0.1:2.0#curr_T = 200:10:380, curr_P = 1:25:1050
#         plot(grid, m .* grid)
#     end

#     return a

# end

# webio_serve(page("/", app), port=5055)

# using Mux

# ui = button()
# WebIO.webio_serve(page("/", req -> b), 5055)

# @testset "RadiativeTransfer.jl" begin
#     # Write your tests here.




# end



# using Revise 
# using RadiativeTransfer.CrossSection
# using DelimitedFiles
# using Plots

# # pyplot()

# test_ht = CrossSection.read_hitran("helper/CO2.data", ν_min=6000, ν_max=6400)

# temperatures = [100, 175, 250, 325, 400]
# pressures = [250, 500, 750, 1000, 1250]

# grid = collect(6000:0.01:6400);
# CEF = ErfcHumliErrorFunctionVoigt()

# # Threshold -- our value must be within ϵ of the HAPI value
# ϵ = 3.5e-27

# for temp in temperatures
#     println(temp)
#     for pres in pressures
#         jl_cs = absorption_cross_section(Voigt(CEF),test_ht,grid,false,pres,temp,40,vmr=0)
#         py_cs = readdlm("/home/rjeyaram/RadiativeTransfer/test/helper/Voigt_CO2_T" * string(temp) * "_P" * string(pres) * ".csv")
#         Δcs = abs.(jl_cs - py_cs)

#         display(plot(grid, Δcs, ylims=(0, ϵ)))

#         plot(grid, py_cs, ylims=(0, 1.3*maximum(py_cs)))
#         display(plot!(grid, jl_cs, ylims=(0, 1.3*maximum(py_cs))))

#         # println("Max: ", )
#         # println("MAE: ", mean(Δcs))
#         @test maximum(Δcs) < ϵ
#     end

# end

using Revise
using Profile
using RadiativeTransfer
using RadiativeTransfer.CrossSection

using BenchmarkTools

test_ht = read_hitran("/home/rjeyaram/RadiativeTransfer/test/helper/CO2.data", ν_min=6000, ν_max=6400)

model4 = make_hitran_model(test_ht, Voigt(), architecture = Architectures.CPU())
model4_GPU = make_hitran_model(test_ht, Voigt(), architecture = Architectures.GPU())

ν_grid = 6000:0.01:6400
pressures = 250:250:1250
temperatures = 100:75:400

model = make_interpolation_model(test_ht, Voigt(), ν_grid, pressures, temperatures, wing_cutoff = 40, CEF=ErfcHumliErrorFunctionVoigt())

matrix = Array(model.itp)

res = absorption_cross_section(model, 6000:0.01:6400, 1000.1, 296.1)

f(x) = sum(sin, x) + prod(tan, x) * sum(sqrt, x);
x = rand(4);

result = DiffResults.HessianResult(x)
result = ForwardDiff.hessian!(result, f, x);

const ν_grid = 6000:0.01:6400

absorption_cross_section(model4, ν_grid, 1000.1, 296.1)
@btime absorption_cross_section(model4_GPU, )

@time absorption_cross_section(model4_GPU, ν_grid, 1000.1, 296.1)

@code_warntype testReturn(3)


x = [1000.1, 296.1]
result = DiffResults.HessianResult(x)

result = ForwardDiff.hessian!(result, CrossSection.acs_shorthand, x);

x = [0.3, 6.82, 1.3, 0.00001]
result = DiffResults.JacobianResult(zeros(4568), x)
ForwardDiff.jacobian!(result, PhaseFunction.phase_shorthand, x);
