using CPLEX
using JuMP
using Random

"""
p prépapratuer considéré
O = OF + OS -> les orders de OF sont les OF premières ensuite viennent les variables de OS 
Capa le vecteur des capacités des pickers 
"""

function esclave(N, R, O, q, s, OF, OS, Capa, p, alpha, beta)
    println("Lancement Resolution PLNE pour le sous problème esclave : ", p)

    # Créer le modèle
    # m = Model(optimizer_with_attributes(CPLEX.Optimizer, "CPX_PARAM_TILIM" => temps_max))
    m = JuMP.Model(CPLEX.Optimizer)

    @variable(m, x[1:O], Bin)
    @variable(m, y[1:R], Bin)

    @constraint(m, sum(x[o] for o = 1:O) <= Capa[p]) # p a une capacité limité
    for i in 1:N
        @constraint(m, sum(s[i][r]*y[r] for r = 1:R) >= sum(q[i][o]*x[o] for o in 1:O)) #Chaque picker doit pouvoir remplir les commandes qui lui sont attribuées avec les racks dont il dispose
    end
    
    # Fonction objective si on maximize le nombre de commande
    # @objective(m, Max, sum(x[o] for o in OS) - sum(alpha[o]*x[o] for o in OS) - sum(alpha[o]*x[o] for o in OF) - sum(beta[r]*y[r] for r in R))
    @objective(m, Max, sum(x[o] for o in OS))

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

function generer_vk(N, R, O, q, s, OF, OS, Capa, P, alpha, beta)
    xk_transpose = []
    yk_transpose = []
    Vk = (Vector{Vector{Int}}[], Vector{Vector{Int}}[])
    cred_plus_gamma = 0

    # Fusion des listes x et y en Vk
    for p in 1:P
        objective_value,x,y = esclave(N, R, O, q, s, OF, OS, Capa, p, alpha, beta)
        push!(xk_transpose, [x[o] for o in 1:O])
        push!(yk_transpose, [y[r] for r in 1:R])
        println(alpha)
        println(x)
        println(beta)
        println(y)
        cred_plus_gamma += objective_value - sum(alpha[o]*x[o] for o in OS) - sum(alpha[o]*x[o] for o in OF) - sum(beta[r]*y[r] for r in R)
        # cred_plus_gamma += objective_value
    end
    Vk = ([[xk_transpose[p][o] for p in 1:P] for  o in 1:O], [[yk_transpose[p][r] for p in 1:P] for r in 1:R])
    return Vk, cred_plus_gamma
end