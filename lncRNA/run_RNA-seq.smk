SAMPLES = {'P50_AC1','P50_AC2','P50_AC3','P50_CK1','P50_CK2','P50_CK3'}
gtf = '/home/kyh/Desktop/MJ20221219388_datarelease/new_genome/ncbi_silkworm_ac_lnc_sorted.gtf'
index = '/home/kyh/Desktop/MJ20221219388_datarelease/new_genome/silkworm_Ac_ht_index'
rule all:
  input:
    expand("clean_data/{sample}.clean.R1.paired.fq.gz",sample=SAMPLES),
    expand("clean_data/{sample}.clean.R2.paired.fq.gz",sample=SAMPLES),
    expand("sortedbam/{sample}.bam",sample=SAMPLES),
    "counts.txt"


rule hisat2_map:
  input:
    clean_R1 = "clean_data/{sample}.clean.R1.paired.fq.gz",
    clean_R2 = "clean_data/{sample}.clean.R2.paired.fq.gz"
  output:
    temp('sam/{sample}.sam')
  log:
    "sam/{sample}_mapping_log.txt"
  threads: 40
  shell:
    "hisat2 -p {threads} -x {index} --dta -1 {input.clean_R1} -2 {input.clean_R2} -S {output} 2>{log}"

rule samtools_sort:
  input:
    temp('sam/{sample}.sam')
  output:
    'sortedbam/{sample}.bam'
  threads: 40
  shell:
    'samtools sort -@ {threads} -o {output} {input}'

rule counts:
  input:
    gtf = {gtf},
    bam = expand('sortedbam/{sample}.bam',sample=SAMPLES)
  output:
    "counts.txt"
  threads: 40
  shell:
    "featureCounts -a {input.gtf} -O -M -o {output} -T {threads} {input.bam}"
