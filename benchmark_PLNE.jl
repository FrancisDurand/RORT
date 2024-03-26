using CPLEX
using JuMP
using Random
using Base
include("plne_base.jl")
include("lecture.jl")
include("decomposition.jl")


const instance_list = (
    parse_data("data/Data_test_N5_R2_O3_RS2.txt"),
    parse_data("data/Data_test_N5_R3_O3_RS5.txt"),
    parse_data("data/Data_test_N5_R4_O3_RS2.txt"),
    parse_data("data/Data_test_N7_R4_O6_RS7.txt"),
    parse_data("data/Data_test_N7_R5_O5_RS7.txt"),
    parse_data("data/Data_test_N7_R5_O6_RS7.txt"),
    parse_data("data/Data_test_N10_R10_O10_RS7.txt"),
    parse_data("data/Data_test_N12_R12_O12_RS8.txt"),
    parse_data("data/instance_N100_R50_O50_RS25"),
    parse_data("data/instance_N100_R100_O100_RS25"),
    parse_data("data/instance_N100_R100_O150_RS25"),
    parse_data("data/instance_N200_R50_O50_RS25"),
    parse_data("data/instance_N200_R100_O100_RS25"))




temps_max = 6000000000

for instance ∈ instance_list
    data = instance
    println("test plne base")
    println("instance : N = ", data.N, ", R = ", data.R, ", O = ", data.O, ", RS = ", data.RS )
    start_time = time()
    objective_sol, x_sol, y_sol = resolution(data.N, data.R, data.O, data.Q, data.S, data.FO, data.SO, data.P, data.Capa, temps_max)
    println("RESOLUTION instance : N = ", data.N, ", R = ", data.R, ", O = ", data.O, ", RS = ", data.RS, ", objectif =", objective_sol, ", Time = ", time()-start_time)
    sleep(1)
end

