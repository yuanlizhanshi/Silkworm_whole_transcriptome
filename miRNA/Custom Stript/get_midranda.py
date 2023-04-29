import sys 



def usage():
    print('Usage: python script.py [midranda_output] [outfile_name]')


def main():
    with open(sys.argv[1], 'r') as infile:
        with open(sys.argv[2], 'w') as outfile:
            for line in infile:
                if line.startswith('>'):
                    if line.startswith('>>'):
                        pass
                    else:
                        line = line.split('>')[1]
                        outfile.write(line)


try:
    main()
except IndexError:
    usage()



