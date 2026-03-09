Class {
	#name : 'BaselineOfMooseGraphRAG',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfMooseGraphRAG',
	#package : 'BaselineOfMooseGraphRAG'
}

{ #category : 'baselines' }
BaselineOfMooseGraphRAG >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfMooseGraphRAG >> defineDependencies: spec [

	 spec
        baseline: 'PharoArrow'
        with: [ spec
            repository: 'github://badetitou/PharoArrow:main/src' ].


]

{ #category : 'baselines' }
BaselineOfMooseGraphRAG >> defineGroups: spec [

]

{ #category : 'baselines' }
BaselineOfMooseGraphRAG >> definePackages: spec [

	spec
		package: 'MooseGraphRAG'
		with: [ spec requires: #( 'PharoArrow' ) ]
]
