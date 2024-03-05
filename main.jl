using CPLEX
using JuMP

"""

P nombre de prépapratuers
O = OF + OS -> les orders de OF sont les OF premières ensuite viennent les variables de OS 
Capa le vecteur des capacités des pickers 

"""
function resolution(N, R, O, q, s, OF, OS, P, Capa, temps_max)

    # Créer le modèle
    m = Model(optimizer_with_attributes(CPLEX.Optimizer, "CPX_PARAM_TILIM" => temps_max))
    # m = JuMP.Model(CPLEX.Optimizer)

    @variable(m, x[1:O, 1:P], Bin)
    for o in 1:OF
        @constraint(m, sum(x[o, p] for p = 1:P) == 1) # les commandes primaires doivent être satisfaites
    end

    for o in (OF+1):O
        @constraint(m, sum(x[o, p] for p = 1:P) <= 1) # Les commandes secondaires peuvent être satisfaites
    end
    

    @variable(m, y[1:R, 1:P], Bin)
    for r in 1:R
        @constraint(m, sum(y[r, p] for p = 1:P) <= 1) # Chaque rack est utilisé au plus une fois
    end

    for p in 1:P
        @constraint(m, sum(x[o,p] for o = 1:O) <= Capa[p]) # Chaque picker a une capacité limité
        for i in 1:N
            @constraint(m, sum(s[i,r]*y[r,p] for r = 1:R) >= sum(q[i,o]*x[o,p] for o in 1:O)) #Chaque picker doit pouvoir remplir les commandes qui lui sont attribuées avec les racks dont il dispose
        end
    end
    
    # Fonction objective si on maximize le nombre de commande
    @objective(m, Max, sum(x[o,p] for o in (OF+1):O for p in 1:P))


    # # Fonction objective si on minimize le nombre de racks
    # @objective(m, Min, sum(y[r,p] for r in 1:R for p in 1:P))

    # Résoudre le modèle
    optimize!(m)
end