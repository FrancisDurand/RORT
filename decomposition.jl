using CPLEX
using JuMP
using Random
include("master_problem.jl")
include("esclave.jl")

function decomposition_DW_pickers()
    # Creer la première solution
    v = []
    #Il faut v non vide au début, genre mettre un élément admissible

    max_iteration = 100
    iter_number = 0

    while not opt and iter_number < max_iteration:
        iter_number += 1

        # resoudre le probleme maitre
        objectiveValue, sol_lambda, dual_value = master_problem(N, R, O, q, s, OF, OS, P, Capa, temps_max, v)

        # resoudre les sous-problemes
        alpha =
        beta =
        nouveau_v = generer_vk(N, R, O, q, s, OF, OS, Capa, P, alpha, beta)

        #calcul coûts réduits ?

        #update de la liste v

        #Garder au fur et à mesure les meilleure borne et meilleure solution admissible
    end
end