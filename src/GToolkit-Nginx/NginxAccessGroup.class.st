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
