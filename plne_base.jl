"""
P nombre de prépapratuers
O = OF + OS -> les orders de OF sont les OF premières ensuite viennent les variables de OS 
Capa le vecteur des capacités des pickers 
"""
function resolution(N, R, O, q, s, OF, OS, P, Capa, temps_max)
    println("Lancement Resolution PLNE")

    # Créer le modèle
    m = Model(optimizer_with_attributes(CPLEX.Optimizer, "CPX_PARAM_TILIM" => temps_max))
    # m = JuMP.Model(CPLEX.Optimizer)

    @variable(m, x[1:O, 1:P], Bin)
    @variable(m, y[1:R, 1:P], Bin)

    for o in OF
        @constraint(m, sum(x[o, p] for p = 1:P) == 1) # les commandes primaires doivent être satisfaites
    end

    for o in OS
        @constraint(m, sum(x[o, p] for p = 1:P) <= 1) # Les commandes secondaires peuvent être satisfaites
    end
    
    for r in 1:R
        @constraint(m, sum(y[r, p] for p = 1:P) <= 1) # Chaque rack est utilisé au plus une fois
    end

    for p in 1:P
        @constraint(m, sum(x[o,p] for o = 1:O) <= Capa[p]) # Chaque picker a une capacité limité
        for i in 1:N
            @constraint(m, sum(s[i][r]*y[r,p] for r = 1:R) >= sum(q[i][o]*x[o,p] for o in 1:O)) #Chaque picker doit pouvoir remplir les commandes qui lui sont attribuées avec les racks dont il dispose
        end
    end
    
    # Fonction objective si on maximize le nombre de commande
    @objective(m, Max, sum(x[o,p] for o in OS for p in 1:P))

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
        sol_x = JuMP.value.(x)
        sol_y = JuMP.value.(y)

        # Si la solution optimale n'est pas obtenue
        # if termination_status(m) ≠ MOI.OPTIMAL

        #     # Le solveur fournit la meilleure borne supérieure connue sur la solution optimale
            
        # end 
        return objectiveValue, sol_x, sol_y
    else
        println("Aucun solution trouvée dans le temps imparti.")
        bound = JuMP.objective_bound(m)
        return bound,bound, bound
    end
end