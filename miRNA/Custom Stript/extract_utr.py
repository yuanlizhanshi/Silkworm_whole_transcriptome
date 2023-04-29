from Bio import SeqIO
import re
import sys 
def usage():
	print('Usage: python script.py [fasta_file] [outfile_name]')



def main():
	records = SeqIO.parse(sys.argv[1], "fasta")
	outf = open(sys.argv[2],'w')
	mRNA_seq = {}
	for record in records:
		if 'CDS' not in record.description:
			continue
		cds_start, cds_end = map(int, re.search(r"CDS=(\d+)-(\d+)", record.description).groups())
		seq = str(record.seq)
		mRNA_seq[record.id] = seq[cds_end:]

	# output length > 30 UTR
	for key, value in mRNA_seq.items():
		if value != '':
		    if len(value) >= 30:
			    outf.write(">{}".format(key)+'\n')
			    outf.write(value+'\n')

if __name__ == '__main__':
    try:
        main()
    except IndexError:
        usage()
