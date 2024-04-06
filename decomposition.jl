using CPLEX
using JuMP
using Random
include("master_problem.jl")
include("esclave.jl")

function generate_initial_solution(N, R, O, q, s, OF, OS, P, Capa)
    println("Géneration d'une solution initiale ...")
    solution_trouvee = false
    x = [[0 for p in 1:P] for o in 1:O]
    y = [[0 for p in 1:P] for r in 1:R]
    while !solution_trouvee
        x = [[0 for p in 1:P] for o in 1:O]
        y = [[0 for p in 1:P] for r in 1:R]
        for o in OF
            p_random = rand(1:P)
            x[o][p_random] = 1
        end
        for r in 1:R
            p_random = rand(1:P)
            y[r][p_random] = 1
        end
        admissible = true
        for p in 1:P
            if admissible && sum([x[o][p] for o in 1:O]) > Capa[p]
                admissible = false
            end
            for i in 1:N
                if admissible && sum([q[i][o] * x[o][p] for o in 1:O]) > sum([s[i][r] * y[r][p] for r in 1:R])
                    admissible = false
                end
            end
        end
        solution_trouvee = admissible
    end
    println("Solution initiale construite")
    return x, y
end

function decomposition_DW_pickers(N, R, O, q, s, OF, OS, P, Capa, temps_max)
    # Creer la première solution
    v = []
    liste_borne_inf = []
    liste_borne_sup = []

    #solution initiale
    x_ini, y_ini = generate_initial_solution(N, R, O, q, s, OF, OS, P, Capa)
    push!(v, (x_ini, y_ini))

    max_iteration = 10
    iter_number = 0
    opt = false

    while !opt && iter_number < max_iteration
        iter_number += 1

        # resoudre le probleme maitre
        objectiveValue, sol_lambda, alpha, beta, gamma = master_problem(N, R, O, q, s, OF, OS, P, Capa, temps_max, v)

        # resoudre les sous-problemes
        nouveau_v, cred_plus_gamma = generer_vk(N, R, O, q, s, OF, OS, Capa, P, alpha, beta)

        #calcul coûts réduits
        cred = cred_plus_gamma + gamma

        if cred > 10e-6
            #update de la liste v
            push!(v, nouveau_v)
        else
            opt = true
        end
            
        #Garder au fur et à mesure les bornes
        borne_inf = objectiveValue
        borne_sup = objectiveValue + cred

        push!(liste_borne_inf, borne_inf)
        push!(liste_borne_sup, borne_sup)
    end

    return liste_borne_inf, liste_borne_sup
end