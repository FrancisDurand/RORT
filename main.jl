using CPLEX
using JuMP
using Random
include("plne_base.jl")
include("lecture.jl")
include("decomposition.jl")


function main()
    println("----------------------------------------------------------------------------")
    #data = parse_data("data/Data_test_N12_R12_O12_RS8.txt")
    data = parse_data("data/Data_test_N5_R4_O3_RS2.txt")
    temps_max = 60

    if false
        println("test plne base")
        objective_sol, x_sol, y_sol = resolution(data.N, data.R, data.O, data.Q, data.S, data.FO, data.SO, data.P, data.Capa, temps_max)
        println(x_sol)
        println(y_sol)
    end

    if true
        println("test decomposition")
        decomposition_DW_pickers(data.N, data.R, data.O, data.Q, data.S, data.FO, data.SO, data.P, data.Capa, temps_max)
    end

end

main()