Class {
	#name : #NginxAccessGroup,
	#superclass : #Object,
	#instVars : [
		'accesses'
	],
	#category : #'GToolkit-Nginx-GToolkit-Nginx'
}

{ #category : #accessing }
NginxAccessGroup >> accesses [
	^ accesses
]

{ #category : #accessing }
NginxAccessGroup >> accesses: aSortedList [
	accesses := aSortedList
]

{ #category : #accessing }
NginxAccessGroup >> add: anNginxAccess [
	accesses add: anNginxAccess
]

{ #category : #accessing }
NginxAccessGroup >> groupedByDate [
	|result gr |
	result := Dictionary new.
	accesses do: [:each |
		gr := result at: (each datetime asDate) ifAbsentPut: [ NginxAccessGroup new].
		gr add: each].
	^ NginxAccessGroupedGroup new groupDictionary: result.
]

{ #category : #accessing }
NginxAccessGroup >> gtAllAccessesFor: aView [
	<gtView>
	accesses ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'All Accesses';
		priority: 3;
		items: [ accesses ];
		column: 'Time'
			item:
				[ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ]
			width: 180;
		column: 'IP'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem ip ]
			width: 100; 
		
		column: 'Access'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem accessedURL ];
		column: 'Agent'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem agent ];
		column: 'Channel'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem channel ]
			width: 10
]

{ #category : #accessing }
NginxAccessGroup >> gtByDayFor: aView [
	<gtView>
	^ self groupedByDate gtByDayFor: aView
]

{ #category : #accessing }
NginxAccessGroup >> initialize [
	accesses := OrderedCollection new.
]
