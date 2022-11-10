# datastore-registry
Track the four-digit unique "KEY4" key used in Data Store collections - and the associated directory path information: Genus, species, datatype, accession.typeVer

For example:
```
  2KSV	Glycine	falcata	annotations	G1718.gnm1.ann1
  B1PY	Glycine	falcata	genomes	G1718.gnm1
  SS25	Glycine	max	annotations	FiskebyIII.gnm1.ann1
  320V	Glycine	max	annotations	Hefeng25_IGA1002.gnm1.ann1
```

Typical usage:
```
  ./register_key.pl -m "Pisum sativum genomes Cameor.gnm1" -stdout
```
  
This will generate (for example; the key will be unique for each run):
```
  C6BT	Pisum	sativum	genomes	Cameor.gnm1
```

If the previous command is issued without "-stdout", then the record will be added to the ds_registry.tsv file.

The script can also be provided with a key (for example, if a curator has already been working on a collection and has provisionally assigned a key):
```
  ./register_key.pl -k XXXX -m "Mus musclus annotations Minnie.gnm1.ann1" 
```

Once satisfied with the results, then push to the remote (origin) repository.


