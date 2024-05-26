using CPLEX
using JuMP
using Random
include("plne_base.jl")
include("lecture.jl")
include("decomposition.jl")

function main()
    println("----------------------------------------------------------------------------")
    # data = parse_data("data/Data_test_N12_R12_O12_RS8.txt")
    data = parse_data("data/Data_test_N5_R4_O3_RS2.txt")
    #data = parse_data("data/instance_N100_R50_O50_RS25")
    #data = parse_data("data/instance_N100_R100_O100_RS25")
    temps_max = 60

    if false
        println("test plne base")
        objective_sol, x_sol, y_sol = resolution(data.N, data.R, data.O, data.Q, data.S, data.FO, data.SO, data.P, data.Capa, temps_max)
        println(x_sol)
        println(y_sol)
        print(objective_sol)
    end

    if true
        println("test decomposition")
        liste_borne_inf, liste_borne_sup = decomposition_DW_pickers(data.N, data.R, data.O, data.Q, data.S, data.FO, data.SO, data.P, data.Capa, temps_max)
        println(liste_borne_inf)
        println(liste_borne_sup)
    end

end

main()