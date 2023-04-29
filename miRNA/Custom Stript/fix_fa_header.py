import sys 

def usage():
    print('Usage: python script.py [fasta_file] [outfile_name]')


def main():
    with open(sys.argv[1], 'r') as infile:
        with open(sys.argv[2], 'w') as outfile:
            for line in infile:
                if line.startswith('>'):
                    line = line.split()[0] +'\n'
                    
                if not line.startswith('-'):
                    outfile.write(line)


try:
    main()
except IndexError:
    usage()



