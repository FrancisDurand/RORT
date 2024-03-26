

function master_problem(N, R, O, q, s, OF, OS, P, Capa, temps_max, v)
    println("Lancement Resolution master problem")

    # Créer le modèle
    m = Model(optimizer_with_attributes(CPLEX.Optimizer, "CPX_PARAM_TILIM" => temps_max))
    # m = JuMP.Model(CPLEX.Optimizer)

    V = size(v)[1]
    println("taille de v : ", V)

    @variable(m, lambda[1:V])

    for o in OF
        @constraint(m, sum(lambda[k] * v[k][1][o][p] for p = 1:P, k = 1:V) == 1) # les commandes primaires doivent être satisfaites
    end

    for o in OS
        @constraint(m, sum(lambda[k] * v[k][1][o][p]  for p = 1:P, k = 1:V) <= 1) # Les commandes secondaires peuvent être satisfaites
    end
    
    for r in 1:R
        @constraint(m, sum(lambda[k] * v[k][2][r][p]  for p = 1:P, k = 1:V) <= 1) # Chaque rack est utilisé au plus une fois
    end

    @constraint(m, sum(lambda[k] for k = 1:V) == 1) # Convexité
    @constraint(m, [k in 1:V], lambda[k] >= 0)
    
    # Fonction objective si on maximize le nombre de commande

    @objective(m, Max, sum(lambda[k] * v[k][1][o][p] for p = 1:P for k = 1:V for o in OS ))

    # # Fonction objective si on minimize le nombre de racks
    # @objective(m, Min, sum(y[r,p] for r in 1:R for p in 1:P))

    # Résoudre le modèle
    optimize!(m)

    ### Si une solution a été trouvée dans le temps limite
    if primal_status(m) == MOI.FEASIBLE_POINT
        # Afficher la valeur de l'objectif
        objectiveValue = round(Int, JuMP.objective_value(m))
        #println("Valeur de l'objectif : ", round(Int, JuMP.objective_value(m)))

        #println("Solution : ")
        sol_lambda = JuMP.value.(lambda)
        dual_value = m.solution.get_dual_values()

        # Si la solution optimale n'est pas obtenue
        if termination_status(m) ≠ MOI.OPTIMAL

            # Le solveur fournit la meilleure borne supérieure connue sur la solution optimale
            bound = JuMP.objective_bound(m)
        end 
        return objectiveValue, sol_lambda, dual_value
    else
        println("Aucun solution trouvée dans le temps imparti.")
    end
end