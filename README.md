# Silkworm_whole_transcriptome
 This Repository contain several indiviual script and analysis pipeline for whole transcriptome upsteam analysis

 ## For long non coding RNA

### 1. Run qc in your raw fastq file 

Using [fastp](https://github.com/OpenGene/fastp) to trim reads and filter low quality reads

>fastp -w 16 -i raw_1.fastq.gz -o clean.R1.fq.gz -I raw_2.fastq.gz -O clean.R2.fq.gz

### 2. Remove unpaired reads (optional) and aggregate reads form all samples 

#fix unpaired reads with [seqkit](https://bioinf.shenwei.me/seqkit/usage/)
>seqkit pair -1 $i.clean.R1.fq.gz -2 $i.clean.R2.fq.gz

#concatenate reads 
>cat *.clean.R1.paired.fq.gz > all_R1.fq.gz\
>cat *.clean.R2.paired.fq.gz > all_R2.fq.gz


### 3. Generate a new reference genome which contain silkworm and AcMNPV genome

>cat ncbi_silkworm_genome.fa AcMNPV.fa > ncbi_silkworm_Ac_genome.fa \
cat ncbi_genome_bm.gtf AcMNPV.gtf >ncbi_silkworm_Ac_genome.gtf

### 4. Build genome index

Using [hisat2](https://github.com/DaehwanKimLab/hisat2):\
`hisat2_extract_splice_sites.py ncbi_silkworm_Ac_genome.gtf > splice.txt
hisat2_extract_exons.py ncbi_silkworm_Ac_genome.gtf > exons.txt
hisat2-build -p 40 ncbi_silkworm_Ac_genome.fa --ss splice.txt --exon exons.txt silkworm_Ac_ht_index`

### 5. Mapping to the reference genome

`hisat2 --dta -p 40 -1 all_R1.fq.gz -2 all_R2.fq.gz -x silkworm_Ac_ht_index |samtools view -q 10 -b - > all.bam`

>samtools sort -@ 40 -o all_sorted.bam all.bam

### 6. Run stringtie to detect new transcript

Using [stringtie](https://github.com/gpertea/stringtie) to identify new transcript

This optional if your gtf is not incompatible with stringtie (because stringtie can't accept transcript_id == '' ):
awk -F '\t' '$3 != "gene" ' ../../new_genome/ncbi_silkworm_Ac_genome.gtf > ncbi_stringtie_fix.gtf

stringtie all_sorted.bam -m 200 -p 40 -G ncbi_stringtie_fix.gtf -T 1 -o new.gtf

### 7. Annotate the long non coding RNA
Run [FEELnc](https://github.com/tderrien/FEELnc) 3 steps to find new long non coding RNA.
It is recommend to use conda to install FEELnc.
>FEELnc_filter.pl -i new.gtf -a ncbi_stringtie_fix.gtf -b transcript_biotype=protein_coding 
\> candidate_lncRNA.gtf

>FEELnc_codpot.pl -i candidate_lncRNA.gtf 
-a ncbi_stringtie_fix.gtf -l Bombyx_mori.lncRNA.fa -g ncbi_silkworm_Ac_genome.fa

>FEELnc_classifier.pl -i feelnc_codpot_out candidate_lncRNA.gtf.lncRNA.gtf -a ncbi_stringtie_fix.gtf > lncRNA_classes.txt

### 7. Merge all gtf
>stringtie --merge -G ncbi_stringtie_fix ./feelnc_codpot_out/candidate_lncRNA.gtf.lncRNA.gtf -o ncbi_silkworm_Ac_lnc.gtf

### 8. Quantify expression of all gene in gtf
>snakemake -s run_RNA-seq.smk -c 40