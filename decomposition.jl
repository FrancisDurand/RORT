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

    #Il faut v non vide au début, genre mettre un élément admissible
    x_ini, y_ini = generate_initial_solution(N, R, O, q, s, OF, OS, P, Capa)
    push!(v, (x_ini, y_ini))

    max_iteration = 100
    iter_number = 0
    opt = false
    println("AFFICHAGE de v")
    println(v)

    while !opt && iter_number < max_iteration
        iter_number += 1

        # resoudre le probleme maitre
        objectiveValue, sol_lambda, alpha, beta = master_problem(N, R, O, q, s, OF, OS, P, Capa, temps_max, v)

        println("afficher")
        println("valeur objectif actuel : ", objectiveValue, "\n")
        println(sol_lambda)
        println(alpha)
        println(beta)


        # C'est une tentative de coder la condition d'arret mais ça marhce pas
        # b = true
        # for o in 1:O
        #     if alpha[o] >= 0 + 1e-6
        #         b = false
        #     end
        # end
        # if b
        #     for r in 1:R
        #         if beta[r] >= 0 + 1e-6
        #             b = false
        #         end
        #     end
        # end
        # opt = b
        # resoudre les sous-problemes
        #alpha =
        #beta =
        nouveau_v = generer_vk(N, R, O, q, s, OF, OS, Capa, P, alpha, beta)

        #calcul coûts réduits ?

        #update de la liste v
        push!(v, nouveau_v)
        

        #Garder au fur et à mesure les meilleure borne et meilleure solution admissible
    end
    objectiveValue, sol_lambda, alpha, beta = master_problem(N, R, O, q, s, OF, OS, P, Capa, temps_max, v)

    println("afficher")
    println("valeur objectif actuel : ", objectiveValue)
    println(sol_lambda)
    println(alpha)
    println(beta)
end