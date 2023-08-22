#!/bin/bash




D=3300

Dmax=60

Dmin=60

Pmax=${D}

Pmin=2

Kmax=55

Kmin=55

Cmax=${D}


phimax=0

Dmax_EMBV=${Dmax}

most_related_crosses_removed=0


if [ ${set_phi_constraints} == "false" ]
then

    set_phi_phile=NA
fi

if [ ${set_starting_pop} == "false" ]
then

    set_starting_pop_phile=NA
fi


