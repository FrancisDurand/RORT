using CPLEX
using JuMP
using Random
include("plne_base.jl")
include("lecture.jl")


function main()
    println("----------------------------------------------------------------------------")
    data = parse_data("data/Data_test_N5_R4_O3_RS2.txt")
    temps_max = 60
    objective_sol, x_sol, y_sol = resolution(data.N, data.R, data.O, data.Q, data.S, data.FO, data.SO, data.P, data.Capa, temps_max)
end

main()