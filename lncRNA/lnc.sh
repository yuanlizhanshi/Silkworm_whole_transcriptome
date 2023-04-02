# 1. Run qc 
for i in $(ls *.fastq.gz |rev |cut -c 17-23 |rev|uniq)
do
echo $i 'begin'
fastp -w 16 -i $i.R1.raw.fastq.gz -o ../clean_data/$i.clean.R1.fq.gz -I $i.R2.raw.fastq.gz -O ../clean_data/$i.clean.R2.fq.gz
done

# 2. Remove unpaired reads and aggregate reads form all samples
for i in $(ls *.fq.gz |rev |cut -c 16- |rev|uniq)
do
echo $i 'begin'
seqkit pair -1 $i.clean.R1.fq.gz -2 $i.clean.R2.fq.gz
done

cat *.clean.R1.paired.fq.gz > ../run_lnc_identify/all_R1.fq.gz
cat *.clean.R2.paired.fq.gz > ../run_lnc_identify/all_R2.fq.gz



# 3. Generate to the new reference genome which contaim sikworm and AcMNPV
cat ncbi_silkworm_genome.fa AcMNPV.fa > ncbi_silkworm_Ac_genome.fa
cat ncbi_genome_bm.gtf AcMNPV.gtf >ncbi_silkworm_Ac_genome.gtf
hisat2_extract_splice_sites.py ncbi_silkworm_Ac_genome.gtf > splice.txt
hisat2_extract_exons.py ncbi_silkworm_Ac_genome.gtf > exons.txt
hisat2-build -p 40 ncbi_silkworm_Ac_genome.fa --ss splice.txt --exon exons.txt silkworm_Ac_ht_index

# 4. Mapping to the reference genome
hisat2 --dta -p 40 -1 all_R1.fq.gz -2 all_R2.fq.gz -x ../../new_genome/silkworm_Ac_ht_index |samtools view -q 10 -b - > all.bam
samtools sort -@ 40 -o all_sorted.bam all.bam

#91.17% overall alignment rate

# 6. Run stringtie to detect new transcript
awk -F '\t' '$3 != "gene" ' ../../new_genome/ncbi_silkworm_Ac_genome.gtf > ncbi_stringtie_fix.gtf
#can't accept transcript_id == '' 
stringtie all_sorted.bam -m 200 -p 40 -G ncbi_stringtie_fix.gtf -T 1 -o new.gtf 


# 7. Annotate the noncoding RNA

~/Desktop/MJ20221219388_datarelease/lncRNA/feelnc/bin/FEELnc_filter.pl -i new.gtf \
-a ncbi_stringtie_fix2.gtf \
-b transcript_biotype=protein_coding \
> candidate_lncRNA.gtf

~/Desktop/MJ20221219388_datarelease/lncRNA/feelnc/bin/FEELnc_codpot.pl -i candidate_lncRNA.gtf \
-a ncbi_stringtie_fix2.gtf -l Bombyx_mori.lncRNA.fa -g ../../new_genome/ncbi_silkworm_Ac_genome.fa

FEELnc_classifier.pl -i feelnc_codpot_out/candidate_lncRNA.gtf.lncRNA.gtf -a ncbi_stringtie_fix.gtf > lncRNA_classes.txt

# 8. Merge all gtf
stringtie --merge -G ncbi_stringtie_fix ./feelnc_codpot_out/candidate_lncRNA.gtf.lncRNA.gtf -o ../../new_genome/ncbi_silkworm_Ac_lnc.gtf
# 9. Quantify genes in gtf
snakemake -s run_RNA-seq.smk -c 40
