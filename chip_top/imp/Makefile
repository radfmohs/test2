
# -----------------------------------------------------------------------------
# Abstract: GNU Makefile for reference implementation scripts
# -----------------------------------------------------------------------------
#
# Notes:
# Ensure appropriate EDA tools are on search path before using make targets
# Refer to supplied documentation for required EDA tools and versions
#
# -----------------------------------------------------------------------------

intro:
	@echo "Refer to supplied documentation for reference implementation"
	@echo
	@echo "Make targets are available for:"
	@echo "synthesis, dft"
	@echo
	@echo "Make targets included combining the above: front"
	@echo

PHONY: clean clean_all dist_clean

#####################################
# CLEAN                             #
#####################################

clean clean_all dist_clean:
	@echo "Cleaning implementation build directory ....."
	@/bin/rm -rf work${WORK}/*
	@/bin/rm -rf logs/*
	@/bin/rm -rf data/*
	@/bin/rm -rf reports/*

clean_work:
	@echo "Cleaning work directory ....."
	@/bin/rm -rf work${WORK}/*

SDF ?= 
DCT ?= 
DMSA ?= no
MODE ?= functional
CORNER ?= max
scenario ?=S111
STAGE ?= 
COMP  ?= yes
BUD ?= yes
BUD_OPT ?=

#####################################
# Define SDF                        #
#####################################
ifeq ($(SDF),yes)
	SDF_STR = set generate_sdf sdf 
	SDF_OP = sdf
	SDF_STR_ATPG = -env generate_sdf sdf
else 
	SDF_STR = set generate_sdf no_sdf
	SDF_OP = no_sdf
	SDF_STR_ATPG = -env generate_sdf no_sdf
endif

#####################################
# Define BUD                        #
#####################################
ifeq ($(BUD),yes)
	BUD_STR = set bottom_up yes 
  BUD_OPT = bottom_up 
else 
	BUD_STR = set bottom_up no 
endif

#####################################
# Define DMSA                        #
#####################################
ifeq ($(DMSA),yes)
	DMSA_OP = dmsa
else 
	DMSA_OP = nodmsa
endif

#####################################
# Define CORNER                     #
#####################################
ifeq ($(CORNER),min)
	CORN_OP = set corner min
else ifeq ($(CORNER),typ) 
	CORN_OP = set corner typ 
else
	CORN_OP = set corner max
endif

#####################################
# Synthesis & DFT                   #
#####################################

init:
	@if [ ! -d work ] ; then \
          mkdir work${WORK}; \
        fi
	@if [ ! -d logs ] ; then \
          mkdir logs; \
        fi

synthesis:
ifeq ($(BUD),yes)
	cd work${WORK}; (time dc_shell -topo -64bit -x "${SDF_STR};" -f ../scripts/Nanochap_imp_syn_l3.tcl | tee ../logs/synthesis_l3_${SDF_OP}_${BUD_OP}${WORK}.log) 
	cd work${WORK}; (time dc_shell -topo -64bit -x "${SDF_STR};" -f ../scripts/Nanochap_imp_syn_l2.tcl | tee ../logs/synthesis_l2_${SDF_OP}_${BUD_OP}${WORK}.log) 
endif
	cd work${WORK}; (time dc_shell -topo -64bit -x "${SDF_STR}; ${BUD_STR};" -f ../scripts/Nanochap_imp_syn.tcl | tee ../logs/synthesis_${SDF_OP}_${BUD_OP}${WORK}.log) 

dft: #dependency is: synthesis
	cd work${WORK}; (time dc_shell -topo -64bit -x "${SDF_STR}; ${BUD_STR};" -f ../scripts/Nanochap_imp_dft.tcl | tee ../logs/dft_${SDF_OP}_${BUD_OP}${WORK}.log) 


#####################################
# ECO	 			    #
#####################################

syn_eco: #dependency is: pt_dft_min
	cd work${WORK}; (time dc_shell -x "set stage postscan_pteco" -f ../scripts/Nanochap_imp_eco.tcl  | tee ../logs/syn_eco${WORK}.log) 

syn_eco_dct: #dependency is: pt_dft_min
	cd work${WORK}; (time dc_shell -x "set stage postscan_dct_pteco" -f ../scripts/Nanochap_imp_eco.tcl  | tee ../logs/syn_eco_dct${WORK}.log) 

syn_eco2: #dependency is: pt_dft_min
	cd work${WORK}; (time dc_shell -x "set stage postscan_pteco2" -f ../scripts/Nanochap_imp_eco.tcl  | tee ../logs/syn_eco2${WORK}.log) 

syn_eco2_pg: ##dependency is: pt_eco_min_sdf
	cd work${WORK}; (time dc_shell -x "set stage postscan_pteco2" -f ../scripts/Nanochap_imp_pg.tcl  | tee ../logs/syn_eco2_pg${WORK}.log) 

#####################################
# LOGICAL EQUIVALENCE               #
#####################################

lec_synthesis: #dependency is: synthesis
	cd work${WORK}; (time fm_shell -64bit -x "set stage prescan; ${SDF_STR}; ${DCT_STR}" -overwrite -name_suffix "Nanochap_ENS2.synthesis" -f ../scripts/Nanochap_imp_fm.tcl | tee ../logs/lec_synthesis_${SDF_OP}${WORK}.log) 
	cd work${WORK}; mv formality_Nanochap_ENS2.synthesis${WORK}.log ../reports/lec_prescan${STAGE}_${SDF_OP}/formality_Nanochap_ENS2.synthesis${WORK}.log

lec_dft: #dependency is: dft
	cd work${WORK}; (time fm_shell -64bit -x "set stage postscan; ${SDF_STR}; ${DCT_STR}" -overwrite -name_suffix "Nanochap_ENS2.dft" -f ../scripts/Nanochap_imp_fm.tcl | tee ../logs/lec_dft_${SDF_OP}${WORK}.log) 
	cd work${WORK}; mv formality_Nanochap_ENS2.dft${WORK}.log ../reports/lec_postscan${STAGE}_${SDF_OP}/formality_Nanochap_ENS2.dft${WORK}.log

lec_postlayout: #dependency is: dft
	cd work${WORK}; (time fm_shell -64bit -x "set stage postlayout; ; ${SDF_STR}; ${DCT_STR}" -overwrite -name_suffix "Nanochap_ENS2.postlayout" -f ../scripts/Nanochap_imp_fm.tcl | tee ../logs/lec_postlayout${WORK}.log) 
	cd work${WORK}; mv formality_Nanochap_ENS2.postlayout${WORK}.log ../reports/lec_postscan/formality_Nanochap_ENS2.postlayout${WORK}.log

#####################################
# STA               		    #
#####################################
pt_dft_eco: #dependency is: dft
	cd work${WORK}; (time pt_shell -x "set stage postscan_dct; ${CORN_OP}; set scenario ${scenario}; set dmsa ${DMSA}" -f ../scripts/Nanochap_imp_pt_eco.tcl | tee ../logs/pt_dft_eco_${CORNER}_sdf_${scenario}_${DMSA_OP}${WORK}.log) 

pt_dft_eco2: #dependency is: dft
	cd work${WORK}; (time pt_shell -x "set stage postscan_pteco; ${CORN_OP}; set scenario ${scenario}; set dmsa ${DMSA}" -f ../scripts/Nanochap_imp_pt_eco.tcl | tee ../logs/pt_dft_eco2_${CORNER}_sdf_${scenario}_${DMSA_OP}${WORK}.log)

pt_posteco: ##dependency is: syn_eco
	cd work${WORK}; (time pt_shell -x "set stage postscan_pteco; ${CORN_OP}; set scenario ${scenario}" -f ../scripts/Nanochap_imp_pt.tcl | tee ../logs/pt_posteco_${CORNER}_sdf_${scenario}${WORK}.log) 

pt_eco_master: ##dependency is: pt_posteco
	cd work${WORK}; (time pt_shell -multi -f ../scripts/Nanochap_imp_pt_eco_master.tcl | tee ../logs/pt_eco_master_sdf${WORK}.log) 

pt_px: ##dependency is: dft
	cd work${WORK}; (time pt_shell -x "set stage postscan; ${CORN_OP}; ${SDF_STR};" -f ../scripts/Nanochap_imp_pt_px.tcl | tee ../logs/pt_px_${CORNER}_${SDF_OP}${WORK}.log) 

#####################################
# ATPG              		            #
#####################################
atpg_gen:
ifeq ($(STAGE),postlayout)
	@perl scripts/fix_inout_atpg_postlayout.pl /projects/libs/ens2/digital_work/GY_ENS2_DIG/pnr/SPO/SPO_1408/Nanochap_ENS2.output.v 
endif 
	cd work${WORK}; tmax -shell -64 -env stage ${STAGE} -env COMP ${COMP} ${SDF_STR_ATPG} ${DCT_STR_ATPG} -tcl ../scripts/Nanochap_imp_tmax.tcl | tee -i ../logs/Nanochap_imp_tmax_${STAGE}_${SDF_OP}_${DCT_OP}${WORK}.log;

atpg:
	make atpg_gen STAGE=postscan COMP=yes SDF=${SDF} DCT=${DCT}

atpg_sdf:
	make atpg_gen STAGE=postscan_pteco COMP=yes SDF=${SDF} DCT=${DCT}

atpg_internal:
	make atpg_gen STAGE=postscan COMP=no SDF=${SDF} DCT=${DCT}

atpg_postlayout:
	make atpg_gen STAGE=postlayout COMP=yes SDF=no DCT=yes

#####################################
# COMBINED TARGETS                  #
#####################################
front: synthesis dft; # pt_px_max pt_px_min pt_px_typ

lec: lec_synthesis lec_dft

#scenario SXY => X: 1=Normal Mode, 2=CP test Mode, 3=Bist Mode, 4=Scan Mode. Y: 1=Internal Clock, 2=External Clock. Z: SPI phase/pol mode
scen_list_nodmsa = S112 S121 S122 S22 S3 S4
scen_list_dmsa = S111 S112 S121 S122 S22 S3 S4

pt:
ifeq ($(DCT),no)
	make pt_dft_eco syn_eco CORNER=max MODE=functional DCT=no
	make pt_dft_eco2 syn_eco2 CORNER=min MODE=functional DCT=no 
	make pt_dft_eco2 syn_eco2 CORNER=max MODE=scan DCT=no 
	make pt_dft_eco2 syn_eco2 CORNER=min MODE=scan DCT=no
	make pt_posteco CORNER=max MODE=functional DCT=no 
	make pt_posteco CORNER=typ MODE=functional DCT=no 
	make pt_posteco CORNER=min MODE=functional DCT=no 
	make pt_posteco CORNER=max MODE=scan DCT=no 
	make pt_posteco CORNER=typ MODE=scan DCT=no 
	make pt_posteco CORNER=min MODE=scan DCT=no
	make syn_eco2_pg DCT=no
else ifeq ($(DMSA),no)
	make pt_dft_eco CORNER=max MODE=functional scenario=S111; make syn_eco_dct;
	@for scen in $(scen_list_nodmsa); do \
		make pt_dft_eco2 CORNER=max MODE=functional scenario=$$scen; \
		make syn_eco2; \
	done
	make pt_dft_eco2 CORNER=min MODE=functional scenario=S111; make syn_eco2;
	@for scen in $(scen_list_nodmsa); do \
		make pt_dft_eco2 CORNER=min MODE=functional scenario=$$scen; \
		make syn_eco2; \
	done
	make syn_eco2_pg
else
	@for scen in $(scen_list_dmsa); do \
		make pt_dft_eco CORNER=max MODE=functional scenario=$$scen; \
	done
	@for scen in $(scen_list_dmsa); do \
		make pt_dft_eco CORNER=min MODE=functional scenario=$$scen; \
	done
	make pt_eco_master
	make syn_eco_dct
	@for scen in $(scen_list_dmsa); do \
	  make pt_posteco CORNER=max MODE=functional scenario=$$scen; \
	  make pt_posteco CORNER=typ MODE=functional scenario=$$scen; \
	  make pt_posteco CORNER=min MODE=functional scenario=$$scen; \
	done
	make syn_eco2_pg
endif

rerun:
	make front lec atpg SDF=no DCT=yes
	make front lec pt atpg_sdf SDF=yes DCT=yes DMSA=yes
	make clean_work

#####################################
# SYNC to HZ and SG                 #
#####################################
sync:
	csh upload.csh ens2 ens2mb

test: 
	@for scen in $(scen_list_dmsa); do \
	  make pt_posteco CORNER=max MODE=functional scenario=$$scen; \
	  make pt_posteco CORNER=typ MODE=functional scenario=$$scen; \
	  make pt_posteco CORNER=min MODE=functional scenario=$$scen; \
	done
