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
	#category : 'MooseGraphRAG-Parquet',
	#package : 'MooseGraphRAG',
	#tag : 'Parquet'
}

{ #category : 'entities' }
MooseParquetExporter >> buildEntitiesColumns [
	"Builder by field"

	| idBuilder titleBuilder descriptionBuilder idArray titleArray descriptionArray columns listBuilder listArray humanIdBuilder humanIdArray degreeBuilder degreeArray typeBuilder typeArray |
	"create builder"
	idBuilder := arrowLibrary garrow_string_array_builder_new.
	humanIdBuilder := arrowLibrary garrow_int64_array_builder_new.
	titleBuilder := arrowLibrary garrow_string_array_builder_new.
	typeBuilder := arrowLibrary garrow_string_array_builder_new.
	descriptionBuilder := arrowLibrary garrow_string_array_builder_new.
	listBuilder := arrowLibrary
		               garrow_list_array_builder_new: listStringType
		               error: nil.
	degreeBuilder := arrowLibrary garrow_int64_array_builder_new.

	"business logic here"

	self model allModelEntities do: [ :entity | "we do not deal with association here"
		entity isAssociation ifFalse: [
			arrowLibrary
				garrow_string_array_builder: idBuilder
				_append_string: entity mooseID printString
				error: nil.
			arrowLibrary
				garrow_int64_array_builder: humanIdBuilder
				_append_value: entity mooseID
				error: nil.
			arrowLibrary
				garrow_string_array_builder: titleBuilder
				_append_string: (self nameOf: entity)
				error: nil.
			typeBuilder append: entity class name.
			arrowLibrary
				garrow_string_array_builder: descriptionBuilder
				_append_string: entity class name
				error: nil.
			arrowLibrary
				garrow_list_array_builder_append_value: listBuilder
				error: nil.
			arrowLibrary
				garrow_int64_array_builder: degreeBuilder
				_append_value: 1
				error: nil ] ].

	"end builder"
	idArray := arrowLibrary
		           garrow_array_builder_finish: idBuilder
		           error: nil.
	humanIdArray := arrowLibrary
		                garrow_array_builder_finish: humanIdBuilder
		                error: nil.

	titleArray := arrowLibrary
		              garrow_array_builder_finish: titleBuilder
		              error: nil.
	typeArray := typeBuilder finish.
	descriptionArray := arrowLibrary
		                    garrow_array_builder_finish: descriptionBuilder
		                    error: nil.
	listArray := arrowLibrary
		             garrow_array_builder_finish: listBuilder
		             error: nil.
	degreeArray := arrowLibrary
		               garrow_array_builder_finish: degreeBuilder
		               error: nil.


	"have columns in my memory"
	columns := nil.
	columns := gLibrary g_list_append: columns with: idArray.
	columns := gLibrary g_list_append: columns with: humanIdArray.
	columns := gLibrary g_list_append: columns with: titleArray.
	columns := gLibrary g_list_append: columns with: typeArray.
	columns := gLibrary g_list_append: columns with: descriptionArray.
	columns := gLibrary g_list_append: columns with: listArray.
	columns := gLibrary g_list_append: columns with: degreeArray.

	^ columns
]

{ #category : 'entities' }
MooseParquetExporter >> buildEntitiesParquet [

	| schema table columns writer |
	schema := self prepareTableSchema.
	columns := self buildEntitiesColumns.

	"create table"
	table := arrowLibrary
		         garrow_table_new_values: schema
		         values: columns
		         error: nil.

	"write the file now"
	writer := parquetLibrary
		          gparquet_arrow_file_writer_new_path: schema
		          path: '/Users/benoit.verhaeghe/Documents/entities.parquet'
		          writerProperties: nil
		          error: nil.
	parquetLibrary
		gparquet_arrow_file_writer_write_table: writer
		table: table
		chunkSize: 10000
		error: nil.

	"if everything goes well, you can close the writer here"
	parquetLibrary gparquet_arrow_file_writer_close: writer error: nil
]

{ #category : 'relationships' }
MooseParquetExporter >> buildRelationshipsColumns [

	| descriptionBuilder descriptionArray columns sourceBuilder targetBuilder weightBuilder sourceArray targetArray weightArray idBuilder idArray listBuilder listArray humanIdBuilder humanIdArray combinedDegreeBuilder combinedDegreeArray |
	"create builder"
	idBuilder := arrowLibrary garrow_string_array_builder_new.
	humanIdBuilder := arrowLibrary garrow_int64_array_builder_new.
	sourceBuilder := arrowLibrary garrow_string_array_builder_new.
	targetBuilder := arrowLibrary garrow_string_array_builder_new.
	descriptionBuilder := arrowLibrary garrow_string_array_builder_new.
	weightBuilder := arrowLibrary garrow_float_array_builder_new.
	listBuilder := arrowLibrary
		               garrow_list_array_builder_new: listStringType
		               error: nil.
	combinedDegreeBuilder := arrowLibrary garrow_int64_array_builder_new.


	"business logic here"

	self model allModelEntities do: [ :entity | "we do not deal with association here"
		entity isAssociation
			ifFalse: [ "self halt.
				arrowLibrary
					garrow_string_array_builder: sourceBuilder
					_append_string: entity source mooseID printString
					error: nil.
				arrowLibrary
					garrow_string_array_builder: targetBuilder
					_append_string: entity mooseName
					error: nil.
				arrowLibrary
					garrow_string_array_builder: descriptionBuilder
					_append_string: entity class name
					error: nil.
				arrowLibrary
					garrow_float_array_builder: weightBuilder
					_append_value: 1.0
					error: nil"
				 ]
			ifTrue: [
				| target |
				target := entity target.
				(target isCollection not or: [ target isNotEmpty ]) ifTrue: [
					target isCollection ifTrue: [ target := target anyOne ].

					arrowLibrary
						garrow_string_array_builder: idBuilder
						_append_string: entity mooseID printString
						error: nil.
					arrowLibrary
						garrow_int64_array_builder: humanIdBuilder
						_append_value: entity mooseID
						error: nil.
					arrowLibrary
						garrow_string_array_builder: sourceBuilder
						_append_string: (self nameOf: entity source)
						error: nil.
					arrowLibrary
						garrow_string_array_builder: targetBuilder
						_append_string: (self nameOf: target)
						error: nil.
					arrowLibrary
						garrow_string_array_builder: descriptionBuilder
						_append_string: entity class name
						error: nil.
					arrowLibrary
						garrow_float_array_builder: weightBuilder
						_append_value: 1.0
						error: nil.
					arrowLibrary
						garrow_list_array_builder_append_value: listBuilder
						error: nil.
					arrowLibrary
						garrow_int64_array_builder: combinedDegreeBuilder
						_append_value: 2
						error: nil ] ] ].

	"end builder"
	idArray := arrowLibrary
		           garrow_array_builder_finish: idBuilder
		           error: nil.
	humanIdArray := arrowLibrary
		                garrow_array_builder_finish: humanIdBuilder
		                error: nil.
	sourceArray := arrowLibrary
		               garrow_array_builder_finish: sourceBuilder
		               error: nil.
	targetArray := arrowLibrary
		               garrow_array_builder_finish: targetBuilder
		               error: nil.
	descriptionArray := arrowLibrary
		                    garrow_array_builder_finish: descriptionBuilder
		                    error: nil.
	weightArray := arrowLibrary
		               garrow_array_builder_finish: weightBuilder
		               error: nil.
	listArray := arrowLibrary
		             garrow_array_builder_finish: listBuilder
		             error: nil.
	combinedDegreeArray := arrowLibrary
		                       garrow_array_builder_finish:
		                       combinedDegreeBuilder
		                       error: nil.

	"have columns in my memory"
	columns := nil.
	columns := gLibrary g_list_append: columns with: idArray.
	columns := gLibrary g_list_append: columns with: humanIdArray.
	columns := gLibrary g_list_append: columns with: sourceArray.
	columns := gLibrary g_list_append: columns with: targetArray.
	columns := gLibrary g_list_append: columns with: descriptionArray.
	columns := gLibrary g_list_append: columns with: weightArray.
	columns := gLibrary g_list_append: columns with: listArray.
	columns := gLibrary g_list_append: columns with: combinedDegreeArray.
	^ columns
]

{ #category : 'relationships' }
MooseParquetExporter >> buildRelationshipsParquet [

	| schema table columns writer |
	schema := self prepareRelationshipsTableSchema.
	columns := self buildRelationshipsColumns.

	"create table"
	table := arrowLibrary
		         garrow_table_new_values: schema
		         values: columns
		         error: nil.

	"write the file now"
	writer := parquetLibrary
		          gparquet_arrow_file_writer_new_path: schema
		          path: '/Users/benoit.verhaeghe/Documents/relationships.parquet'
		          writerProperties: nil
		          error: nil.
	parquetLibrary
		gparquet_arrow_file_writer_write_table: writer
		table: table
		chunkSize: 10000
		error: nil.

	"if everything goes well, you can close the writer here"
	parquetLibrary gparquet_arrow_file_writer_close: writer error: nil
]

{ #category : 'initialization' }
MooseParquetExporter >> initialize [

	super initialize.
	arrowLibrary := PharoArrowLibrary uniqueInstance.
	gLibrary := PharoGLibLibrary uniqueInstance.
	parquetLibrary := PharoParquetLibrary uniqueInstance
]

{ #category : 'accessing' }
MooseParquetExporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetExporter >> model: anObject [

	model := anObject
]

{ #category : 'accessing - name' }
MooseParquetExporter >> nameOf: aMooseConcept [

	^ aMooseConcept mooseName , '.' , aMooseConcept mooseID printString
]

{ #category : 'relationships' }
MooseParquetExporter >> prepareRelationshipsTableSchema [
	"I need id (int) title (string) description (string)"

	| strType fields idField descriptionField schema floatType sourceField targetField weightField textUnitIdsField textUnitIdField intType humanIdField combinedDegreeField |
	intType := arrowLibrary garrow_int64_data_type_new.
	strType := arrowLibrary garrow_string_data_type_new.
	floatType := arrowLibrary garrow_float_data_type_new.

	"Create the fields"
	idField := arrowLibrary garrow_field_new: 'id' dataType: strType.
	humanIdField := arrowLibrary
		                garrow_field_new: 'human_readable_id'
		                dataType: intType.
	sourceField := arrowLibrary
		               garrow_field_new: 'source'
		               dataType: strType.
	targetField := arrowLibrary
		               garrow_field_new: 'target'
		               dataType: strType.
	descriptionField := arrowLibrary
		                    garrow_field_new: 'description'
		                    dataType: strType.
	weightField := arrowLibrary
		               garrow_field_new: 'weight'
		               dataType: floatType.
	textUnitIdField := arrowLibrary
		                   garrow_field_new: 'text_unit_id'
		                   dataType: strType.
	listStringType := arrowLibrary garrow_list_data_type_new:
		                  textUnitIdField.
	textUnitIdsField := arrowLibrary
		                    garrow_field_new: 'text_unit_ids'
		                    dataType: listStringType.
	combinedDegreeField := arrowLibrary
		                       garrow_field_new: 'combined_degree'
		                       dataType: intType.

	fields := nil.
	fields := gLibrary g_list_append: fields with: idField.
	fields := gLibrary g_list_append: fields with: humanIdField.
	fields := gLibrary g_list_append: fields with: sourceField.
	fields := gLibrary g_list_append: fields with: targetField.
	fields := gLibrary g_list_append: fields with: descriptionField.
	fields := gLibrary g_list_append: fields with: weightField.
	fields := gLibrary g_list_append: fields with: textUnitIdsField.
	fields := gLibrary g_list_append: fields with: combinedDegreeField.

	"arrow schema from our usage"
	schema := arrowLibrary garrow_schema_new: fields.
	^ schema
]

{ #category : 'entities' }
MooseParquetExporter >> prepareTableSchema [
	"I need id (int) title (string) description (string)"

	| strType fields idField titleField descriptionField schema textUnitIdsField textUnitIdField intType humanIdField degreeField typeField |
	strType := arrowLibrary garrow_string_data_type_new.
	intType := arrowLibrary garrow_int64_data_type_new.


	"Create the fields"
	idField := arrowLibrary garrow_field_new: 'id' dataType: strType.
	humanIdField := arrowLibrary
		                garrow_field_new: 'human_readable_id'
		                dataType: intType.
	titleField := arrowLibrary
		              garrow_field_new: 'title'
		              dataType: strType.
	typeField := arrowLibrary garrow_field_new: 'type' dataType: strType.
	descriptionField := arrowLibrary
		                    garrow_field_new: 'description'
		                    dataType: strType.
	textUnitIdField := arrowLibrary
		                   garrow_field_new: 'text_unit_id'
		                   dataType: strType.
	listStringType := arrowLibrary garrow_list_data_type_new:
		                  textUnitIdField.
	textUnitIdsField := arrowLibrary
		                    garrow_field_new: 'text_unit_ids'
		                    dataType: listStringType.
	degreeField := arrowLibrary
		               garrow_field_new: 'degree'
		               dataType: intType.


	fields := nil.
	fields := gLibrary g_list_append: fields with: idField.
	fields := gLibrary g_list_append: fields with: humanIdField.
	fields := gLibrary g_list_append: fields with: titleField.
	fields := gLibrary g_list_append: fields with: typeField.
	fields := gLibrary g_list_append: fields with: descriptionField.
	fields := gLibrary g_list_append: fields with: textUnitIdsField.
	fields := gLibrary g_list_append: fields with: degreeField.

	"arrow schema from our usage"
	schema := arrowLibrary garrow_schema_new: fields.
	^ schema
]
