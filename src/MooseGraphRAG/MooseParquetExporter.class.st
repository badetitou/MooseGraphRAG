"
I am a utility that takes as input a Moose Model and ouput `.parquet` files.

I export two files

- `entities.parquet` that contains all the Nodes (including reified association)
- `relationships.parquet` that contains the link between the Nodes
"
Class {
	#name : 'MooseParquetExporter',
	#superclass : 'Object',
	#instVars : [
		'model',
		'arrowLibrary',
		'gLibrary',
		'parquetLibrary',
		'listStringType'
	],
	#category : 'MooseGraphRAG-ParquetExporter',
	#package : 'MooseGraphRAG',
	#tag : 'ParquetExporter'
}

{ #category : 'public' }
MooseParquetExporter >> export [

	| entitiesExporter |
	entitiesExporter := MooseParquetEntitiesExporter new.
	entitiesExporter model: self model.
	entitiesExporter export.
	entitiesExporter := MooseParquetRelationshipsExporter new.
	entitiesExporter model: self model.
	entitiesExporter export
]

{ #category : 'accessing' }
MooseParquetExporter >> model [
	^ model
]

{ #category : 'accessing' }
MooseParquetExporter >> model: aModel [

	model := aModel
]
