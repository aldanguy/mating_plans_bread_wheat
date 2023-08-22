#!/bin/bash




D=3300

Dmax=60

Dmin=5

Pmax=132

Pmin=100

Kmax=300 

Kmin=200

Cmax=250


phimax=${D}

Dmax_EMBV=${Dmax}


most_related_crosses_removed=0.01


if [ ${set_phi_constraints} == "false" ]
then

    set_phi_file=NA
fi

if [ ${set_starting_pop} == "false" ]
then

    set_starting_pop_file=NA
fi

