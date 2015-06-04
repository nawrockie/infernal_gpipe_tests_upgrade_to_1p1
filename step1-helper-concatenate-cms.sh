cat RNaseP_bact_a.cm > ../GPIPE.29.rfam12.i1p0.cm;
for cm in FMN snoPyro_CD SIB_RNA S15 SAM Purine Cobalamin T-box RNaseP_arch DnaX RtT K_chan_RES Glycine L10_leader L20_leader L21_leader c-di-GMP-I isrK STnc490k ALIL cspA ASpks ROSE_2 mycoplasma_FSE neisseria_FSE Phe_leader sX9 Hammerhead_II; do
    cat $cm.cm >> ../GPIPE.29.rfam12.i1p0.cm;
done
