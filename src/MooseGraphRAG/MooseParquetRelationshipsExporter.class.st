Class {
	#name : 'MooseParquetRelationshipsExporter',
	#superclass : 'Object',
	#instVars : [
		'model'
	],
	#category : 'MooseGraphRAG-ParquetExporter',
	#package : 'MooseGraphRAG',
	#tag : 'ParquetExporter'
}

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> buildColumns: relationshipsToExport [
	"export the tabular"

	| columns typeBuilder startNodeBuilder endNodeBuilder typeArray startNodeArray endNodeArray |
	typeBuilder := PharoArrowLibrary uniqueInstance
		               garrow_string_array_builder_new.

	startNodeBuilder := PharoArrowLibrary uniqueInstance
		                    garrow_int64_array_builder_new.
	endNodeBuilder := PharoArrowLibrary uniqueInstance
		                  garrow_int64_array_builder_new.

	"Real logic is here"
	relationshipsToExport do: [ :entity |
		typeBuilder append: entity second name.
		startNodeBuilder append: entity first mooseID.
		endNodeBuilder append: entity third mooseID ].

	typeArray := typeBuilder finish.
	startNodeArray := startNodeBuilder finish.
	endNodeArray := endNodeBuilder finish.
	"have columns in my memory"
	columns := nil.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: typeArray.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: startNodeArray.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: endNodeArray.
	^ columns
]

{ #category : 'api' }
MooseParquetRelationshipsExporter >> export [
	"Perform entities export"

	| schema columns writer table |
	"prepare schema"
	schema := self prepareSchema.
	columns := self buildColumns: (self relationsToExport: self model).
	"create table"
	table := PharoArrowLibrary uniqueInstance
		         garrow_table_new_values: schema
		         values: columns
		         error: nil.
	"write the file now"
	writer := PharoParquetLibrary uniqueInstance
		          gparquet_arrow_file_writer_new_path: schema
		          path: (FileLocator documents / 'relationships.parquet')
				          fullName
		          writerProperties: nil
		          error: nil.
	PharoParquetLibrary uniqueInstance
		gparquet_arrow_file_writer_write_table: writer
		table: table
		chunkSize: 10000
		error: nil.

	"if everything goes well, you can close the writer here"
	PharoParquetLibrary uniqueInstance
		gparquet_arrow_file_writer_close: writer
		error: nil
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> prepareSchema [
	"Perform entities export"

	| strType intType fields schema type startNode endNode |
	"prepare schema"
	strType := PharoArrowLibrary uniqueInstance
		           garrow_string_data_type_new.
	intType := PharoArrowLibrary uniqueInstance
		           garrow_int64_data_type_new.

	type := PharoArrowLibrary uniqueInstance
		        garrow_field_new: 'type'
		        dataType: strType.
	startNode := PharoArrowLibrary uniqueInstance
		             garrow_field_new: 'startNode'
		             dataType: intType.
	endNode := PharoArrowLibrary uniqueInstance
		           garrow_field_new: 'endNode'
		           dataType: intType.

	fields := nil.
	fields := PharoGLibLibrary uniqueInstance
		          g_list_append: fields
		          with: type.
	fields := PharoGLibLibrary uniqueInstance
		          g_list_append: fields
		          with: startNode.
	fields := PharoGLibLibrary uniqueInstance
		          g_list_append: fields
		          with: endNode.
	"arrow schema from our usage"
	schema := PharoArrowLibrary uniqueInstance garrow_schema_new: fields.
	^ schema
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> relationsToExport: aMooseModel [

	| col |
	col := OrderedCollection new.
	aMooseModel entities do: [ :entity |
		entity allDeclaredProperties
			reject: [ :property |
				property isDerived or: [
					property hasOpposite not or: [
						(entity propertyNamed: property name ifAbsent: [ nil ]) isNil ] ] ]
			thenDo: [ :property |
				(entity propertyNamed: property name) isCollection
					ifTrue: [
						(entity propertyNamed: property name) do: [ :value |
							col add: {
									entity.
									property.
									value } ] ]
					ifFalse: [
						col add: {
								entity.
								property.
								(entity propertyNamed: property name) } ] ] ].
	^ col
]
