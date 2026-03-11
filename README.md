# Moose graph RAG

This is an initiative to export Moose in a new format for graph representation

## Installation

```st
Metacello new
  baseline: 'MooseGraphRAG';
  repository: 'github://Evref-BL/MooseGraphRAG:main/src';
  load.
```

## Usage

### Format to represent a Moose Model

#### Export

```st
exporter := MooseParquetExporter new.
exporter model: MooseModel root anyOne.
exporter export.
```

#### Import

```st

modelJava := FamixJavaModel new.
importer := MooseParquetImporter new.
importer model: modelJava.
importer importEntities.
importer importEntitiesProperties.
importer importEntitiesRelationships 
```

### Format for graphRAG

```st
mooseGraphRAG := MooseGraphRAG new.
mooseGraphRAG model: MooseModel root second.
mooseGraphRAG buildEntitiesParquet.
mooseGraphRAG buildRelationshipsParquet.
```
