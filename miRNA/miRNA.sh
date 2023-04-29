fastp -w 10 -i rawdata/L2EGL2003153--P50_AC1.fq.gz -o clean_data/p50_ac1.fq.gz
fastp -w 10 -i rawdata/L2EGL2003154--P50_AC2.fq.gz -o clean_data/p50_ac2.fq.gz
fastp -w 10 -i rawdata/L2EGL2003155--P50_AC3.fq.gz -o clean_data/p50_ac3.fq.gz
fastp -w 10 -i rawdata/L2EGL2003156--P50_CK1.fq.gz -o clean_data/p50_ck1.fq.gz
fastp -w 10 -i rawdata/L2EGL2003157--P50_CK2.fq.gz -o clean_data/p50_ck2.fq.gz
fastp -w 10 -i rawdata/L2EGL2003158--P50_CK3.fq.gz -o clean_data/p50_ck3.fq.gz

python process_fq.py clean_data/p50_ac1.fq.gz trim_data/p50_trim_ac1.fa
python process_fq.py clean_data/p50_ac2.fq.gz trim_data/p50_trim_ac2.fa
python process_fq.py clean_data/p50_ac3.fq.gz trim_data/p50_trim_ac3.fa
python process_fq.py clean_data/p50_ck1.fq.gz trim_data/p50_trim_ck1.fa
python process_fq.py clean_data/p50_ck2.fq.gz trim_data/p50_trim_ck2.fa
python process_fq.py clean_data/p50_ck3.fq.gz trim_data/p50_trim_ck3.fa

bowtie-build ncbi_silkworm_Ac_genome.fa bmor_bt1

mapper.pl trim_data/p50_trim_ac1.fa -o 40 -q -c -j -m -l 18 -p ~/Desktop/MJ20221219388_datarelease/new_genome/bmor_bt1 \
-s collapse_fa/p50_trim_ac1.collapse.fa -t arf/p50_trim_ac1genome.arf -v -o 4 > p50_ac1.log
mapper.pl trim_data/p50_trim_ac2.fa -o 40 -q -c -j -m -l 18 -p ~/Desktop/MJ20221219388_datarelease/new_genome/bmor_bt1 \
-s collapse_fa/p50_trim_ac2.collapse.fa -t arf/p50_trim_ac2genome.arf -v -o 4 > p50_ac2.log
mapper.pl trim_data/p50_trim_ac3.fa -o 40 -q -c -j -m -l 18 -p ~/Desktop/MJ20221219388_datarelease/new_genome/bmor_bt1 \
-s collapse_fa/p50_trim_ac3.collapse.fa -t arf/p50_trim_ac3genome.arf -v -o 4 > p50_ac3.log
mapper.pl trim_data/p50_trim_ck1.fa -o 40 -q -c -j -m -l 18 -p ~/Desktop/MJ20221219388_datarelease/new_genome/bmor_bt1 \
-s collapse_fa/p50_trim_ck1.collapse.fa -t arf/p50_trim_ck1genome.arf -v -o 4 > p50_ck1.log
mapper.pl trim_data/p50_trim_ck2.fa -o 40 -q -c -j -m -l 18 -p ~/Desktop/MJ20221219388_datarelease/new_genome/bmor_bt1 \
-s collapse_fa/p50_trim_ck2.collapse.fa -t arf/p50_trim_ck2genome.arf -v -o 4 > p50_ck2.log
mapper.pl trim_data/p50_trim_ck3.fa -o 40 -q -c -j -m -l 18 -p ~/Desktop/MJ20221219388_datarelease/new_genome/bmor_bt1 \
-s collapse_fa/p50_trim_ck3.collapse.fa -t arf/p50_trim_ck3genome.arf -v -o 4 > p50_ck3.log



for i in *.fa
do
 cmscan -E 0.01 --cpu 8 --tblout ../rfam/$i.tab  ../rfam/database/Rfam.cm $i &
done

python statitcs.py >rfam_stat.txt

perl exclude_rfam.pl

miRDeep2.pl ../../collapse_fa/p50_trim_ac1.collapse.-rfam.fa \
../../../new_genome/ncbi_silkworm_Ac_genome.fasta ../../collapse_fa/p50_trim_ac1.genome.-rfam.arf  \
../../../new_genome/RNA_info/bmo2.fa ../../../new_genome/RNA_info/mature2.fa ../../../new_genome/RNA_info/hairpin2.fa 2>p50_ac1.log

cd ../p50_ac2
miRDeep2.pl ../../collapse_fa/p50_trim_ac2.collapse.-rfam.fa \
../../../new_genome/ncbi_silkworm_Ac_genome.fasta ../../collapse_fa/p50_trim_ac2.genome.-rfam.arf  \
../../../new_genome/RNA_info/bmo2.fa ../../../new_genome/RNA_info/mature2.fa ../../../new_genome/RNA_info/hairpin2.fa 2>p50_ac2.log

cd ../p50_ac3
miRDeep2.pl ../../collapse_fa/p50_trim_ac3.collapse.-rfam.fa \
../../../new_genome/ncbi_silkworm_Ac_genome.fasta ../../collapse_fa/p50_trim_ac3.genome.-rfam.arf  \
../../../new_genome/RNA_info/bmo2.fa ../../../new_genome/RNA_info/mature2.fa ../../../new_genome/RNA_info/hairpin2.fa 2>p50_ac3.log

cd ../p50_ck1
miRDeep2.pl ../../collapse_fa/p50_trim_ac1.collapse.-rfam.fa \
../../../new_genome/ncbi_silkworm_Ac_genome.fasta ../../collapse_fa/p50_trim_ac1.genome.-rfam.arf  \
../../../new_genome/RNA_info/bmo2.fa ../../../new_genome/RNA_info/mature2.fa ../../../new_genome/RNA_info/hairpin2.fa 2>p50_ck1.log

cd ../p50_ck2
miRDeep2.pl ../../collapse_fa/p50_trim_ck2.collapse.-rfam.fa \
../../../new_genome/ncbi_silkworm_Ac_genome.fasta ../../collapse_fa/p50_trim_ck2.genome.-rfam.arf  \
../../../new_genome/RNA_info/bmo2.fa ../../../new_genome/RNA_info/mature2.fa ../../../new_genome/RNA_info/hairpin2.fa 2>p50_ck2.log
cd ../p50_ck3
miRDeep2.pl ../../collapse_fa/p50_trim_ck3.collapse.-rfam.fa \
../../../new_genome/ncbi_silkworm_Ac_genome.fasta ../../collapse_fa/p50_trim_ck3.genome.-rfam.arf  \
../../../new_genome/RNA_info/bmo2.fa ../../../new_genome/RNA_info/mature2.fa ../../../new_genome/RNA_info/hairpin2.fa 2>p50_ck3.log


python extract_utr.py all_transcripts.fa all_utr.fa

miranda bmo2.fa all_utr.fa  -en -15 -strict -out bmo.mir-tar.miranda.res -quiet
 ~/Desktop/MJ20221219388_datarelease/miRNA/pita/pita_prediction.pl -mir bmo2.fa -utr all_utr.fa -prefix bmo.mir_tar.pita
 