from Bio import AlignIO
import argparse


def main():
    with open(args.output, "a") as outfile:
        AlignIO.convert(args.input, "fasta", outfile, "phylip", "DNA")
        outfile.write("\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="script to convert FASTA into some format")
    group_required = parser.add_argument_group('Required options')
    group_required.add_argument('-i', '--input', type=str, help="input concat FASTA file or stdin")
    group_required.add_argument('-o', '--output', type=str, help="output file name")
    args = parser.parse_args()
    main()
