#!/usr/bin/env python3

import glob

# initialize the dictionary to store the counts for each sample
rfam = {}

# get all the annotation files with the "*.tab" suffix
files = glob.glob("*.tab")

# loop through each file and count the RNA molecules
for file in files:
    # extract the sample name from the file name
    sample = file.split("-")[0]

    # initialize the counts for each type of RNA molecule
    rfam[sample] = {'rRNA': 0, 'tRNA': 0, 'snRNA': 0, 'snoRNA': 0, 'scRNA': 0, 'miRNA': 0, 'other': 0}

    # read the file line by line and count the RNA molecules
    with open(file, 'r') as f:
        for line in f:
            line = line.rstrip()

            # ignore comment lines
            if line.startswith('#'):
                continue

            # extract the RNA molecule type from each line
            rfam_type = line.split('\t')[0]

            # update the count for the corresponding RNA molecule type
            if 'rRNA' in rfam_type:
                rfam[sample]['rRNA'] += 1
            elif 'tRNA' in rfam_type:
                rfam[sample]['tRNA'] += 1
            elif rfam_type.startswith('snR'):
                rfam[sample]['snRNA'] += 1
            elif rfam_type.lower().startswith('sno'):
                rfam[sample]['snoRNA'] += 1
            elif 'scRNA' in rfam_type:
                rfam[sample]['scRNA'] += 1
            elif rfam_type.startswith('mir-') or rfam_type.startswith('bantam') or rfam_type.startswith('lin-') or rfam_type.startswith('let-'):
                rfam[sample]['miRNA'] += 1
            else:
                rfam[sample]['other'] += 1

# print the statistics table
print("sample\trRNA\ttRNA\tmiRNA\tsnRNA\tsnoRNA\tscRNA\tother\ttotal")
for sample in sorted(rfam):
    total = sum(rfam[sample].values())
    counts = [rfam[sample]['rRNA'], rfam[sample]['tRNA'], rfam[sample]['miRNA'], rfam[sample]['snRNA'], rfam[sample]['snoRNA'], rfam[sample]['scRNA'], rfam[sample]['other']]

    print(sample + "\t" + "\t".join(str(count) for count in counts) + "\t" + str(total))
