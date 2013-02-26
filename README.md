edgetools
=========

Some utilities for working with edgelists: generating adjacency lists, getting neighbours lists, getting subsets of edgelists based on ego lists.

These scripts are a mixture of bash and python scripts so you will need these dependencies.

# Definitions
An edgelist is a file that defines the connections between a group of nodes. We will call these connections _edges_ and nodes _egos_. Each entry in an edgelist corresponds to a single edge, connecting two nodes (or potentially a node to itself). Edges can contain any number of additional attributes, e.g., weight or time.

# Requirements
These tools expect to be dealing with [CSV](http://en.wikipedia.org/wiki/Comma-separated_values) files, where the first column is the identifier of the _from_ entity and the second is the identifier of the _to_ entity. The assumption is that this file is sorted, according first of all to the alphabetic ordering of the _from_ ego and secondly to the alphabetic ordering of the _to_ ego.

## Changing the delineation of a file 
If your edgelist file is delineated in anything other than commas consider using the following script, replacing `$SEPERATOR` with the separator character (e.g., `|`) you want to replace, and `$file` with the filename.
```bash
sed "s/$SEPARATOR/,/g" $file >> $file.csv
```
To change the delineation of all files in a directory you could use the [replaceSeparator.sh]() bash script; usage as follows:
```bash
replaceSeparator.sh [-v] separator directory
```

## Changing the ordering of a CSV file
We expect CSV files to be column ordered, with the _from_ ego in the first column and the _to_ ego in the second column. 

## Sorting all CSV files in a directory
To sort a CSV file consider using the following script, replacing `$file` with the name of the csv file. This will sort first by the first column (from), then by the second (to):
```bash
sort -t, -k1,1 -k2,2 $file -o $file
```
To sort all CSV files in a directory you could use the [sortAllCSV.sh]() bash script; usage as follows:
```
sortAllCSV.sh [-v] directory
```

# Producing an adjacency file
An Adjacency file is a file that contains the adjacency data from an edgelist. Our adjacency files are in CSV format, where each line contains two entries, one for each ego in an edge. For an edgelist as follows:
```csv
alan,barbara
alan,dom
barbara,cait
```
the corresponding adjacency file would be as follows:
```csv
alan,barbara
alan,dom
barbara,alan
barbara,cait
cait,barbara
dom,alan
```

In order to produce an adjacency list from a directory containing edgelists use the [generateAdjacencyFile.sh]() bash script:
```bash
generateAdjacencyFile.sh [-v] directory outputfile
```

# Finding the neighbours of a group of egos
Once you have an adjacency file in place you can use the [getNeighbours.py]() python script to build a list of neighbours. Its usage is as follows:
```bash
getNeighbours.py [-h] [-v] [--limit limit overflow_file]
    egofilename adjacencyfilename outputfilename
```

E.g., in order to get the neighbours of `alan` in the above dataset you would do the following (assuming `adjacencyfilename` is the name of the generated adjacency file):
```bash
echo "alan" > ego
./getNeighbours.py ego adjacencyfilename neighbour
```
The generated `neighbour` file should look as follows:
```
barbara
dom
```
You could run the script again passing in the `neighbour` file to go one level deeper (e.g., to produce a new file `neighbour.neighbour`. 
In order to produce the seeds for a network you should then concatenate these files, e.g.,
```bash
sort -u ego neighbour neighbour.neighbour > seed_egos
```
`seed_egos` would now contain a subset of the network containing the original seed egos, their neighbours, and their neighbours.

## Ignoring egos with lots of neighbours
You may (for whatever reason) want to ignore egos that have massive numbers of neighbours. The `--limit` parameter helps. 
In order to produce only neighbours that are not massively connected you can pass a limit and an overflow file name to ignore all seed egos that have more than the `limit` of neighbours. The output file will not contain these neighbours and the overflow file will contain the egos that had more than `limit` neighbours.

# Producing a subset of an edgelist based on a collection of seed egos
Once you have a list of egos and want to build an edgelist based on who these egos connected to you can use the [getEdgelists.sh]() script (which uses the [getEdgelist.py]() python script) Its usage is as follows:
```bash
getEdgelists.sh [-v] seedlist edgelistdirectory outputfile
```

This will produce a single edgelist (`outputfile`) containing all edges originating from the egos listed in `seedlist`.


