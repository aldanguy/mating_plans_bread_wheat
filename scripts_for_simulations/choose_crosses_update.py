
# Goal : extract best crosses while controlling number of parents
# input : file with id of parents and performance indicator of each cross
# output : list of choosen crosses

import sys
import random as random
import numpy as np
import pandas as pd
from itertools import islice
import importlib

random.seed(1)
 
for arg in sys.argv : 
    print(arg)

# numero of column in input (3 = u, 5= log_w, 6=UC)
colonne=int(sys.argv[1])-1
# path of output
titre_best_crosses=sys.argv[2]
# path of input
titre_crosses_filtered=sys.argv[3]
# path of cplex programm
titre_path_cplex=sys.argv[4]
D=int(sys.argv[5])
Dmax=int(sys.argv[6])
Dmin=int(sys.argv[7])
Pmax=int(sys.argv[8])
Pmin=int(sys.argv[9])
Kmax=int(sys.argv[10])
Kmin=int(sys.argv[11])
Cmax=int(sys.argv[12])
nbcores=int(sys.argv[13])
critere=sys.argv[14]
# Dmax=10
# D=20
# Pmax=4
# Pmin=4
# Kmax=2
# Kmin=2
# Cmax=10
# Dmin=1

# just for training (not important)
# titre_tab1_variance_crosses="/work/adanguy/these/croisements/031120/tab1_variance_crosses.txt"
# titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"
# nb_parents=130
# nb_crosses=400
# titre_tab1_variance_crosses_filtered="/work/adanguy/these/croisements/031120/tab1_variance_crosses_filtered.txt"
# crosses = {k: crosses[k] for k in random.sample(crosses.keys(),10)}
# crosses = {k: crosses[k] for k in [64980,64981,64982,64983,64984,64985]}
# crosses = {"John_Marie": {'p1': 'John', 'p2': 'Marie', 'u': 3},          "Leo_Cat": {'p1': 'Leo', 'p2': 'Cat', 'u':4},          "Marie_Jean": {'p1': 'Marie', 'p2': 'Jean', 'u':4},          "Jeanne_John": {'p1': 'Jeanne', 'p2': 'Jean', 'u':2}}
#f=pd.read_csv(filename, nrows=2000, header=0, sep="\t")



# import cplex program
MODULE_PATH=titre_path_cplex
MODULE_NAME="cplex"
spec = importlib.util.spec_from_file_location(MODULE_NAME, MODULE_PATH)
module = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = module 
spec.loader.exec_module(module)
import cplex as cplex





############ prepare data




f=open(titre_crosses_filtered)
# column 0 = p1 = ID of parent 1 (character)
# column 1 = p2 = ID of parent 2 (character)
# column 2 = u = expected mean of progeny (numeric)
# column 3 = sd = sd of progreny (numeric)
# column 4 = log_w = probability to produce a progeny lower than a treshold (numeric)
# column 5 = uc = expected mean of top fraction of progeny (numeric)
# first line of f = colnames

# ignore first line
next(f)

# extract info of each cross
crosses={}
for ligne in f :
    buff=ligne.split()
    p1=str(buff[0])
    p2=str(buff[1])
    u=float(buff[colonne])
    crosses[str(p1)+"+"+str(p2)]={}
    crosses[str(p1)+"+"+str(p2)]["p1"]=p1
    crosses[str(p1)+"+"+str(p2)]["p2"]=p2
    crosses[str(p1)+"+"+str(p2)]["u"]=u


f.close()
# crosses is a dictionnary : for each cross i+j, it records the name of parent 1 (pi), parent 2 (pj) and performance indicator (u)    


gain=[]
for id,info in crosses.items():
    gain.append(info['u'])
    
    
# gain is a vector giving performance indicator of each cross i+j


cij=[]
for id,info in crosses.items():
    cij.append(id)
    
# cij is a vector giving a unique ID to each cross





parents=[]
i=0
for id,info in crosses.items():
    parents.append(info["p1"])
    parents.append(info["p2"])
    
    
    
# parents is a vector comprising names of parents in file

# unique set of parents in file
parents=set(parents)


############ CPLEX
  
# initialize cplex model
c=cplex.Cplex()
c.parameters.threads.set(nbcores)
c.parameters.timelimit.set(14400.0)



# ask cplex to maximise the fitness function

if critere == "logw":
    c.objective.set_sense(c.objective.sense.minimize)
else:
    c.objective.set_sense(c.objective.sense.maximize)

# specify fitness function : sum of performance indicator of each cross * number of progeny
# numer of progeny of the cross i*j = cij. These are the variables we are interested in.
# note that the number of progeny per cross can't exceed Dmax
create_cij=c.variables.add(obj=gain, names = cij, lb = [0] * len(cij),  ub = [Dmax] * len(cij),types = ["I"] * len(cij))

# total number of progeny = D
constraint_on_D=c.linear_constraints.add(lin_expr = [cplex.SparsePair(cij,  [1] * len(cij))],   senses = ["E"], rhs = [D])


# for each cross i*j, create a boolean variable which worth 0 if cij=0 and 1 if cij>0
# next command lines allow to link the boolean variable and the number of progeny per cross
couples_used=[]

# iterate over crosses
for couple in cij:

    create_cij_boolean=c.variables.add(names = [couple+"_boolean"], lb = [0],  ub = [1],types = ["B"])
    couples_used.append(couple+"_boolean")
    big_M_constraint2=c.linear_constraints.add(lin_expr = [cplex.SparsePair([couple, couple+"_boolean"],  [1, -1000000])],   senses = ["L"], rhs = [0])
    if Dmin == 0:
        big_M_constraint1=c.linear_constraints.add(lin_expr = [cplex.SparsePair([couple+"_boolean", couple],  [1, -1])],   senses = ["L"], rhs = [0])
    else:
        big_M_constraint1=c.linear_constraints.add(lin_expr = [cplex.SparsePair([couple+"_boolean", couple],  [Dmin, -1])],   senses = ["L"], rhs = [0])



# control number of crosses
constraint_on_Kmax=c.linear_constraints.add(lin_expr = [cplex.SparsePair(couples_used,  [1]*len(couples_used))],   senses = ["L"], rhs = [Kmax])
constraint_on_Kmin=c.linear_constraints.add(lin_expr = [cplex.SparsePair(couples_used,  [1]*len(couples_used))],   senses = ["G"], rhs = [Kmin])

# control on the number of parents used and contribution of each parent.  
# next command lines create a integer variable which gives the number of progenies derived from each parent, and a boolean variable indicating if the parent if choosen or not


parents_used=[]

# iterate over parents
for pi in parents:
	

    # number of progenies derived from each parent
    # note that this can't exceed Cmax
    create_pi=c.variables.add(names = [pi], lb = [0], ub=[1], types = ["B"] )
    parents_used.append(pi)
    
    ci=[]
    # identify crosses involving a specific parent
    # "crosses_involving_pk" will be a vector with at first position value of pk and all other following positions the value of cij involving pk
    for id,info in crosses.items():
        if info["p1"]==pi or info["p2"]==pi:
	# variable id records the ID of crosses i*j involving parent k
            ci.append(id)
            
    
    
    # number of progenies derived from this specific parent
    # make the relationship between pk and cij : sum of cij involving parent k should be equal to pk
    # apply coefficient +1 to pk and -1 to cij involving parent k. The sum of such linear constraint should be equal to 0, so this determine value of pk
    # determine_value_of_pk=c.linear_constraints.add(lin_expr = [cplex.SparsePair(crosses_involving_pk,  [1]+[-1] * (len(crosses_involving_pk)-1))],   senses = ["E"], rhs = [0])  
    

    
    # create boolean variables pk_is_null_or_not. This variable is equal to 0 if pk is null (no choosen crosses involve parent k) and 1 if pk is not pull (at least one choosen cross involved parent k)
    # create_pk_is_null_or_not=c.variables.add(names = [pk+"_is_null_or_not"],types = ["B"] )  
    # "parents_used" is a vector of pk_is_null_or_not
    # parents_used.append(pk+"_is_null_or_not")
    
    # make the relationship between pk_is_null_or_not and pk using big M constraint
    # pk_is_null_or_not - pk <= 0 and pk - M*pk_is_null_or_not <= 0
    
    big_M_constraint3=c.linear_constraints.add(lin_expr = [cplex.SparsePair([pi] + ci, [1]+[-1] * (len(ci)))],   senses = ["L"], rhs = [0])
    big_M_constraint4=c.linear_constraints.add(lin_expr = [cplex.SparsePair(ci +[pi], [1] * (len(ci)) + [-1000000] )],   senses = ["L"], rhs = [0])
    constraint_on_CMAX=c.linear_constraints.add(lin_expr = [cplex.SparsePair(ci, [1] * (len(ci)))],   senses = ["L"], rhs = [Cmax])
    

# control on the number of parents
constraint_on_Pmax=c.linear_constraints.add(lin_expr = [cplex.SparsePair(parents_used,  [1]*len(parents))],   senses = ["L"], rhs = [Pmax])
constraint_on_Pmin=c.linear_constraints.add(lin_expr = [cplex.SparsePair(parents_used,  [1]*len(parents))],   senses = ["G"], rhs = [Pmin])








# solve cplex model
c.solve()
# extract value of all variables (cij, pk, pk_is_null_or_not)
sol=c.solution
v1=c.variables.get_names()
v2=sol.get_values()
dataframe=pd.DataFrame(v1, columns=['name']) 
dataframe["value"]=v2
# extract only cij values
dataframe=dataframe[0:len(crosses)]
dataframe.sort_values("value",  ascending=False)



fitness=sol.get_objective_value()

print("fitness value")
print(fitness)

# save
print("OUTPUT : choosen crosses and parents")
print(dataframe.head())
dataframe.to_csv(titre_best_crosses, index=None, sep='\t', mode='w') 


