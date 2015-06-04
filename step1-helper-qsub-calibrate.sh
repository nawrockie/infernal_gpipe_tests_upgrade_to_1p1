for fam in RF00001.rfam12.i1p0 RNaseP_bact_a FMN snoPyro_CD SIB_RNA S15 SAM Purine Cobalamin T-box RNaseP_arch DnaX RtT K_chan_RES Glycine L10_leader L20_leader L21_leader c-di-GMP-I isrK STnc490k ALIL cspA ASpks ROSE_2 mycoplasma_FSE neisseria_FSE Phe_leader sX9 Hammerhead_II; do
    qsub -N J$fam -b y -v SGE_FACILITIES -P unified -S /bin/bash -cwd -V -j n -o /dev/null -e $fam.err -l h_rt=604800,mem_free=8G,h_vmem=16G -m n "/usr/local/infernal/1.0/bin/cmcalibrate -s 181 $fam.cm > $fam.cmcalibrate"
done
