import argparse
import gzip

def main(args):
    adapter_seq = 'TGGAATTCTCGGGTGCCAAGGAACTC'
    filtered_reads = 0
    seq_count = 0
    
    with gzip.open(args.input_file, 'rt') as f_in, open(args.output_file, 'wt') as f_out:
        while True:
            
            header = f_in.readline().strip()
            if not header:
                break
            seq = f_in.readline().strip()
            plus = f_in.readline().strip()
            qual = f_in.readline().strip()

            #check adapter
            index = seq.find(adapter_seq)
            if index == -1:
                # if without adapter, write raw seq
                seq_count += 1
                f_out.write(f">seq{seq_count}\n{seq}\n")
            else:
                # trim
                trimmed_seq = seq[:index]
                trimmed_qual = qual[:index]
                if len(trimmed_seq) >= 18:
                    seq_count += 1
                    f_out.write(f">seq{seq_count}\n{trimmed_seq}\n")
                else:
                    filtered_reads += 1
                    #print(f"Read {header} discarded due to length {len(trimmed_seq)}< 18bp")
    
    print(f"Done! Trimmed reads saved to {args.output_file}")
    print(f'Total filtered reads: {filtered_reads}')
    
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Trim adapter sequence from reads')
    parser.add_argument('input_file', help='input FASTQ file')
    parser.add_argument('output_file', help='output trimmed fasta file')
    args = parser.parse_args()

    main(args)
