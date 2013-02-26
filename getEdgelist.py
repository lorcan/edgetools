import argparse
import string
import csv
import heapq
from sets import Set

parser = argparse.ArgumentParser(description='Takes a file containing ego identifiers (the seed egos) and a csv edgelist file and produces the subset of the edgelist containing all lines where the first entry is one of the seed list. The edgelist file MUST be sorted.')
parser.add_argument("egofilename", help="This is a file contining one ego identifier per line.")
parser.add_argument("edgelistfilename", help="This is a file containing the edgelist, sorted by the first column, which must be the from identifier.")
parser.add_argument("outputfilename", help="This is the output file, where the new edgelist will be stored.")
parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")

args = parser.parse_args()

def printIfVerbose(string):
  if args.verbose:
    print string

seeds = []
for line in open(args.egofilename, 'r'):
  heapq.heappush(seeds, string.strip(line))
printIfVerbose("Seed egos are: " + str(seeds))

# Now sequentially read the edgelist and produce the subset  
count=0
outputfile = csv.writer(open(args.outputfilename,'w'))
with open(args.edgelistfilename, 'r') as csvfile:
  reader = csv.reader(csvfile)
  nextSeed = heapq.heappop(seeds)
  for row in reader:
    ego = row[0]
    if(ego > nextSeed and len(seeds) > 0):
      # Time to get the next seed ego
      printIfVerbose(nextSeed + " had " + str(count) + " neighbours")
      count = 0
      nextSeed = heapq.heappop(seeds)
    if(ego == nextSeed):
      outputfile.writerow(row)
      count = count + 1
printIfVerbose(nextSeed + " had " + str(count) + " neighbours")

