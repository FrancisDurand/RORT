using CPLEX
using JuMP
using Random

"""
p prépapratuer considéré
O = OF + OS -> les orders de OF sont les OF premières ensuite viennent les variables de OS 
Capa le vecteur des capacités des pickers 
"""

function esclave(N, R, O, q, s, OF, OS, Capa, p, alpha, beta)
    println("Lancement Resolution PLNE")

    # Créer le modèle
    # m = Model(optimizer_with_attributes(CPLEX.Optimizer, "CPX_PARAM_TILIM" => temps_max))
    m = JuMP.Model(CPLEX.Optimizer)

    @variable(m, x[1:O], Bin)
    @variable(m, y[1:R], Bin)

    @constraint(m, sum(x[o,p] for o = 1:O) <= Capa[p]) # p a une capacité limité
    for i in 1:N
        @constraint(m, sum(s[i][r]*y[r,p] for r = 1:R) >= sum(q[i][o]*x[o,p] for o in 1:O)) #Chaque picker doit pouvoir remplir les commandes qui lui sont attribuées avec les racks dont il dispose
    end
    
    # Fonction objective si on maximize le nombre de commande
    @objective(m, Max, sum(x[o] for o in OS) - sum(alpha[o]*x[o] for o in OS) - sum(alpha[o]*x[o] for o in OF) - sum(beta[r]*y[r] for r in R))

    # Résoudre le modèle
    optimize!(m)
    # Afficher la valeur de l'objectif
    objectiveValue = round(Int, JuMP.objective_value(m))
    #println("Valeur de l'objectif : ", round(Int, JuMP.objective_value(m)))

    #println("Solution : ")
    sol_x = JuMP.value.(x)
    sol_y = JuMP.value.(y)

    return objectiveValue, sol_x, sol_y
end