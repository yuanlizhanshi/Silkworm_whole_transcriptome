# Silkworm_whole_transcriptome
 This Repository contain several indiviual script and analysis pipeline for whole transcriptome **upsteam** analysis

## For long non coding RNA
Paired-end 150bp fastq file used in this study.

### 1. Run qc in your raw fastq file 

Using [fastp](https://github.com/OpenGene/fastp) to trim reads and filter low quality reads

>fastp -w 16 -i raw_1.fastq.gz -o clean.R1.fq.gz -I raw_2.fastq.gz -O clean.R2.fq.gz

### 2. Remove unpaired reads (optional) and aggregate reads form all samples 

#fix unpaired reads with [seqkit](https://bioinf.shenwei.me/seqkit/usage/)
>seqkit pair -1 clean.R1.fq.gz -2 clean.R2.fq.gz

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

This optional if your gtf is not incompatible with stringtie (because stringtie can't accept transcript_id == '' ):\
>awk -F '\t' '$3 != "gene" ' ncbi_silkworm_Ac_genome.gtf > ncbi_stringtie_fix.gtf

>stringtie all_sorted.bam -m 200 -p 40 -G ncbi_stringtie_fix.gtf -T 1 -o new.gtf

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

## For microRNA-seq

Single-read 75 bp fastq file used in this study.

### 1. Run qc in your raw fastq file and convert to fasta file
For example:
>fastp -w 10 -i sample.fq.gz -o sample_clean.fq.gz 

In this study , the sequence adapter in fastq files can not auto detected by fastp, we need to trim the reads manually. In this place, the adapter is **TGGAATTCTCGGGTGCCAAGGAACTC**:
>python process_fq.py sample_clean.fq.gz sample_trim.fa

### 2. Mapping reads to genome

In this place, we choose [bowtie](https://github.com/BenLangmead/bowtie) to mapped short reads to previous generated fused genome:
>bowtie-build ncbi_silkworm_Ac_genome.fa bmor_bt1

>mapper.pl sample_trim.fa -o 40 -q -c -j -m -l 18 -p bmor_bt1 
-s sample.collapse.fa -t sample.genome.arf -v -o 4 > sample.log

select mapped reads
grep -f <(awk -F '\t' '{ print $1 }' sample.genome.arf) -A 1 sample.collapse.fa| grep -v '-'> sample_mapped.fa

### 3. Classify reads  
We used [cmscan](https://docs.rfam.org/en/latest/genome-annotation.html) to annotate mapped reads type, then download and built rfam database.
>for i in *.fa\
do\
cmscan -E 0.01 --cpu 8 --tblout ../rfam/$i.tab  ../rfam_database/Rfam.cm $i &\
done

>python statitcs.py >rfam_stat.txt

### 4. Run miRDeep2 for expression matrix

>perl exclude_rfam.pl

#this script require #2 mapping results as input and generate sample.collapse.-rfam.fa and sample.genome.-rfam.arf, please put sample.collapse.fa and sample.genome.arf and stript into the same folder.

[miRDeep2](https://github.com/rajewsky-lab/mirdeep2) only accept fasta file without space, if your fasta file have space, you should fix_fa_header.py to fix your fasta file.

>miRDeep2.pl sample.collapse.-rfam.fa \
ncbi_silkworm_Ac_genome.fasta sample.genome.-rfam.arf \
bmo.fa mature.fa hairpin.fa 2>sample.log



The bmo.fa mature.fa hairpin.fa were download form [miRbase](https://www.mirbase.org/ftp.shtml), which is also in data.tar.gz

See the code generate_count_mat.R to generate count matrix

### 5. microRNA target predict

>python extract_utr.py all_transcripts.fa all_utr.fa

We use [miRanda](https://cbio.mskcc.org/miRNA2003/miranda.html) to finding genomic targets for microRNAs

>miranda bmo.fa all_utr.fa  -en -15 -strict -out bmo.mir-tar.miranda.res -quiet
