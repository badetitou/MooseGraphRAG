Class {
	#name : 'MooseParquetEntitiesExporter',
	#superclass : 'Object',
	#instVars : [
		'model'
	],
	#category : 'MooseGraphRAG-ParquetExporter',
	#package : 'MooseGraphRAG',
	#tag : 'ParquetExporter'
}

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> buildColumns [
	"export the tabular"

	| idBuilder labelBuilder idArray labelArray columns |
	idBuilder := PharoArrowLibrary uniqueInstance
		             garrow_int64_array_builder_new.
	labelBuilder := PharoArrowLibrary uniqueInstance
		                garrow_string_array_builder_new.

	"Real logic is here"
	self model entities do: [ :entity |
		idBuilder append: entity mooseID.
		labelBuilder append: entity mooseDescription fullName ].

	idArray := idBuilder finish.
	labelArray := labelBuilder finish.
	"have columns in my memory"
	columns := nil.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: idArray.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: labelArray.
	^ columns
]

{ #category : 'api' }
MooseParquetEntitiesExporter >> export [
	"Perform entities export"

	| schema columns writer table |
	"prepare schema"
	schema := self prepareSchema.
	columns := self buildColumns.
	"create table"
	table := PharoArrowLibrary uniqueInstance
		         garrow_table_new_values: schema
		         values: columns
		         error: nil.
	"write the file now"
	writer := PharoParquetLibrary uniqueInstance
		          gparquet_arrow_file_writer_new_path: schema
		          path: (FileLocator documents / 'entities.parquet') fullName
		          writerProperties: nil
		          error: nil.
	PharoParquetLibrary uniqueInstance
		gparquet_arrow_file_writer_write_table: writer
		table: table
		chunkSize: 10000
		error: nil.

	"if everything goes well, you can close the writer here"
	PharoParquetLibrary uniqueInstance gparquet_arrow_file_writer_close: writer error: nil
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> prepareSchema [
	"Perform entities export"

	| strType intType idField label fields schema |
	"prepare schema"
	strType := PharoArrowLibrary uniqueInstance
		           garrow_string_data_type_new.
	intType := PharoArrowLibrary uniqueInstance
		           garrow_int64_data_type_new.

	idField := PharoArrowLibrary uniqueInstance
		           garrow_field_new: 'id'
		           dataType: intType.
	label := PharoArrowLibrary uniqueInstance
		           garrow_field_new: 'label'
		           dataType: strType.
	fields := nil.
	fields := PharoGLibLibrary uniqueInstance g_list_append: fields with: idField.
	fields := PharoGLibLibrary uniqueInstance g_list_append: fields with: label.
	"arrow schema from our usage"
	schema := PharoArrowLibrary uniqueInstance garrow_schema_new: fields.
	^ schema
]
