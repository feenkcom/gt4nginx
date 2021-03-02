Class {
	#name : #NginxAccessGroupedGroup,
	#superclass : #Object,
	#instVars : [
		'groupDictionary'
	],
	#category : #'GToolkit-Nginx-GToolkit-Nginx'
}

{ #category : #accessing }
NginxAccessGroupedGroup >> groupDictionary: aGroupDictionary [
	groupDictionary := aGroupDictionary
]

{ #category : #accessing }
NginxAccessGroupedGroup >> gtByDayFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Grouped By Day';
		priority: 3;
		items: [ self sortedByKey ];
		column: 'Day'
			item:
				[ :eachItem :eachIndex | eachItem key ]
			width: 170;
		column: 'Group'
			item: [ :eachItem :eachIndex | eachItem value ]
			text: [:eachItem :eachIndex | eachItem value accesses size ];
		send: [:i | i value]
]

{ #category : #accessing }
NginxAccessGroupedGroup >> sortedByKey [
	^ groupDictionary associations sorted: [:a :b | a key > b key ]
]
