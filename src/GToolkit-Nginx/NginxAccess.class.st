Class {
	#name : #NginxAccess,
	#superclass : #Object,
	#instVars : [
		'accessedURL',
		'datetime',
		'channel',
		'agent',
		'log',
		'parser',
		'ip'
	],
	#category : #'GToolkit-Nginx-GToolkit-Nginx'
}

{ #category : #accessing }
NginxAccess >> accessedURL [
	^ accessedURL
]

{ #category : #accessing }
NginxAccess >> accessedURL: aUrlString [
	accessedURL := aUrlString
]

{ #category : #accessing }
NginxAccess >> agent [
	^ agent
]

{ #category : #accessing }
NginxAccess >> agent: aString [
	agent := aString
]

{ #category : #accessing }
NginxAccess >> channel [
	^ channel
]

{ #category : #accessing }
NginxAccess >> channel: aString [
	channel := aString
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
NginxAccess >> datetime [
	^ datetime
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
			datetime := DateAndTime year: year asInteger month: m day: day asInteger hour: h asInteger minute: min asInteger second: sec asInteger.]
			) parse: datetimesstring .
]

{ #category : #accessing }
NginxAccess >> ip [
	^ ip
]

{ #category : #accessing }
NginxAccess >> ip: anIp [ 
	ip := anIp
]

{ #category : #accessing }
NginxAccess >> log [
	^ log
]

{ #category : #accessing }
NginxAccess >> log: aLogEntry [
	log := aLogEntry
]

{ #category : #accessing }
NginxAccess >> parsed [
	|array|
	self datetime ifNil: [
		array := parser parse: log.
		self ip: array second.
		self datetime: array fourth.
		self accessedURL: array fifth second.
		self channel: (array at: 11) second.
		self agent: (array at: 13)].
]

{ #category : #accessing }
NginxAccess >> parsedForce [
	| array |
	array := parser parse: log.
		self ip: array second.
		self datetime: array fourth.
		self accessedURL: array fifth second.
		self channel: (array at: 11) second.
		self agent: (array at: 13)
]

{ #category : #accessing }
NginxAccess >> parser: aParser [
	parser := aParser
]
