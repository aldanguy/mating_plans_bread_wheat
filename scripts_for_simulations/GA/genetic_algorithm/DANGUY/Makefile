
obin = $(shell opam var bin)
olib = $(shell opam var lib)
CSLC = $(obin)/ocamlc
CSLOPT = $(obin)/ocamlopt
CSLDEP= $(obin)/ocamldep
CAMLLEX= $(obin)/ocamllex
CAMLYACC= $(obin)/ocamlyacc

parmapdir = $(shell opam var parmap:lib)
containersdatadir = $(shell opam var containers-data:lib)

CFILES = mlerf.c
CFLAGS = -O -I $(olib)/ocaml/ 
CLIBS = -lm
COBJS =  $(CFILES:.c=.o)

INCLUDES= -I .. -I $(containersdatadir) -I $(parmapdir) 
CSLFLAGS=$(INCLUDES) -g -custom
CSLOPTFLAGS=$(INCLUDES) 
FILES= vars.ml main.ml
INTERF = $(FILES:.mli=.cmi)
NORM_OBJS =  $(FILES:.ml=.cmo)
OPT_OBJS=  $(FILES:.ml=.cmx)

LIBS= containers_data.cma bigarray.cma str.cma unix.cma parmap.cma ag.cma 

all : test.opt test.norm lpcreate

test.opt :  $(OPT_OBJS) $(COBJS)
	$(CSLOPT) $(CSLOPTFLAGS) -o $@ $(LIBS:.cma=.cmxa) $(OPT_OBJS) $(COBJS)

test.norm :  $(NORM_OBJS) 
	$(CSLC) $(CSLFLAGS) -o $@ $(LIBS) $(NORM_OBJS) $(COBJS)

lpcreate :
	$(CSLOPT) $(CSLOPTFLAGS) -o $@ $(LIBS:.cma=.cmxa) vars.cmx gen_lp2.ml

.SUFFIXES: .mll .mly .ml .mli .cmo .cmi .cmx

.mll.mli:
	$(CAMLLEX) $<
.mll.ml:
	$(CAMLLEX) $<
.mly.mli:
	$(CAMLYACC) $<
.mly.ml:
	$(CAMLYACC) $<
.ml.cmo :
	$(CSLC) $(CSLFLAGS) -c $<
.mli.cmi :
	$(CSLC) $(CSLFLAGS) -c $<
.ml.cmx :
	$(CSLOPT) $(CSLOPTFLAGS) -c $<
.c.o :
	gcc $(CFLAGS) -c $<

clean:
	\rm -f *.cmo *.cmi *.cmx *.o *.a *.cma *.cmxa *.csv alice.lp test.opt test.norm lpcreate .depend *~

.depend:
	$(CSLDEP)  *.mli *.ml >.depend

include .depend
