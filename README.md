# datastore-registry
Track the four-digit unique "KEY4" key used in Data Store collections - and the associated directoyr path information: Genus, species, datatype, accession.typeVer

For example:
```
    2KSV	Glycine	falcata	annotations	G1718.gnm1.ann1
    B1PY	Glycine	falcata	genomes	G1718.gnm1
    SS25	Glycine	max	annotations	FiskebyIII.gnm1.ann1
    320V	Glycine	max	annotations	Hefeng25_IGA1002.gnm1.ann1
```

Typical usage:
    `./add_key_and_value.pl -r registry.tsv -m "Pisum sativum genomes	Cameor.gnm1" -stdout`
    
This will generate (for example; the key will be unique for each run):
    `C6BT	Pisum	sativum	genomes	Cameor.gnm1`

If the previous command is issued without "-stdout", then the record will be added to the registry.tsv file.

Once satisfied with the results, then push to the remote (origin) repository.


