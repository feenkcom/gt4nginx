Class {
	#name : #NginxAccess,
	#superclass : #Object,
	#instVars : [
		'accessedURL',
		'datetime'
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
		#digit asPParser plus flatten token,
		$: asPParser,
		#digit asPParser plus flatten token,
		$: asPParser,
		#digit asPParser plus flatten token,
		$: asPParser,
		#digit asPParser plus flatten token,
		' +0000]' asPParser).
	^ dateParser
]

{ #category : #accessing }
NginxAccess >> datetime: aDatetimeString [
	|datetimesstring day year m h min sec|
	datetimesstring := aDatetimeString.
	(self dateParser 
		==> [:tokens | day := tokens second value.
			m := tokens fourth value.
			year := tokens sixth value.
			h  := (tokens at: 8) value.
			min := (tokens at: 10) value.
			sec  := (tokens at: 12) value.
			datetime := DateAndTime year: day asInteger month: m day: day asInteger hour: h asInteger minute: min asInteger second: sec asInteger.]
			) parse: datetimesstring .
]