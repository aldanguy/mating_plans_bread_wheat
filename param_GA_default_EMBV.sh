#!/bin/bash



set_phi_file=false
set_phi_constraints=false
sharing_used=TRUE
set_starting_pop=true
seed=1
nb_generations_ga=400000



if [ ${set_phi_constraints} == "false" ]
then

    set_phi_phile=NA
fi

if [ ${set_starting_pop} == "false" ]
then

    set_starting_pop_phile=NA
fi


