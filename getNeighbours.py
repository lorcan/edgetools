#!/usr/bin/python
import argparse
import string
import csv
import heapq
from sets import Set

parser = argparse.ArgumentParser(description='Takes a file containing ego identifiers (the seed egos) and a file containing neighbour pairs and produces a file containing the direct neighbours of the seed egos. The neighbour list MUST be sorted.')
parser.add_argument("egofilename", help="This is a file contining one ego identifier per line. It does not need to be sorted.")
parser.add_argument("adjacencyfilename", help="This is a file containing one neighbour pair per line (comma-separated and sorted)")
parser.add_argument("outputfilename", help="This is the output file, where the list of neighbours will be stored.")
parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")
parser.add_argument('--limit',action='store',nargs=2,dest='limit_options',help='Ignores any egos with more than the limit and adds their IDs to the overflow file.',metavar=("limit","overflow_file"))


args = parser.parse_args()
verbose=args.verbose

def printIfVerbose(string):
  if verbose:
    print string

limit=-1
limitoutputfile=None
if args.limit_options is not None:
  limit = int(args.limit_options[0])

def addNeighbours(neighbours, seed_neighbours, seed):
  global limitoutputfile
  if(limit == -1 or len(seed_neighbours) < limit):
    printIfVerbose("{} had {} neighbours".format(seed, len(seed_neighbours)))
    neighbours = neighbours | seed_neighbours
  else:
    printIfVerbose("{} had {} neighbours. This was more than the limit {} set by parameter. We will not add these neighbours. We will add this seed to the overflow file ({}).".format(seed, len(seed_neighbours), limit, args.limit_options[1]))
    if limitoutputfile is None:
      limitoutputfile = open(args.limit_options[1],'w')
    limitoutputfile.write(seed + "\n")
  return neighbours

outputfile = open(args.outputfilename, 'w')

seeds = []
for line in open(args.egofilename, 'r'):
  heapq.heappush(seeds, string.strip(line))

printIfVerbose("Seed egos are: {}".format(seeds))

neighbours = Set()
nextSeed = heapq.heappop(seeds)
seed_neighbours = Set()
printIfVerbose("Starting with seed {}".format(nextSeed))
# Now sequentially get the neighbours  
with open(args.adjacencyfilename, 'r') as csvfile:
  reader = csv.reader(csvfile)
  for row in reader:
    ego = row[0]
    if(ego > nextSeed and len(seeds) > 0):
      neighbours = addNeighbours(neighbours, seed_neighbours, nextSeed)
      seed_neighbours=Set()
      # Time to get the next seed ego
      nextSeed = heapq.heappop(seeds)
      #printIfVerbose("Next seed: {}".format(nextSeed))
    
    if(ego == nextSeed):
      #printIfVerbose("Found neighbour for seed " + nextSeed +": " + row[1] + ".")
      seed_neighbours.add(row[1])

neighbours = addNeighbours(neighbours, seed_neighbours, nextSeed)

sortedNeighbours = []
for neighbour in neighbours:
  heapq.heappush(sortedNeighbours, neighbour)

printIfVerbose("Found {} neighbours in total".format(len(neighbours)))
printIfVerbose("Output neighbours are: {}".format(sortedNeighbours))

for neighbour in sortedNeighbours:
  outputfile.write(neighbour + "\n")

