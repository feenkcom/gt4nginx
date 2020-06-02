Class {
	#name : #NginxAccess,
	#superclass : #Object,
	#instVars : [
		'accessedURL',
		'date'
	],
	#category : #'GToolkit-Nginx-GToolkit-Nginx'
}

{ #category : #accessing }
NginxAccess >> accessedURL: aUrlString [
	accessedURL := aUrlString
]

{ #category : #accessing }
NginxAccess >> dateParser [
	|dateParser|
	dateParser := ($[ asPParser,
		#digit asPParser plus flatten token,
		$/ asPParser,
		#letter asPParser plus flatten token,
		$/ asPParser,
		#digit asPParser plus flatten,
		$: asPParser,
		#digit asPParser plus flatten,
		$: asPParser,
		#digit asPParser plus flatten,
		$: asPParser,
		#digit asPParser plus flatten,
		' +0000]' asPParser
	) flatten.
	^ dateParser
]

{ #category : #accessing }
NginxAccess >> datetime: aDatetimeString [
	|datetimesstring|
	datetimesstring := aDatetimeString.
	(self dateParser ==> [:tokens | date := tokens third ]) parse: datetimesstring .
]
