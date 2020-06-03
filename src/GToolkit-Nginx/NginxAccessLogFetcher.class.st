Class {
	#name : #NginxAccessLogFetcher,
	#superclass : #Object,
	#instVars : [
		'sshServer',
		'log'
	],
	#category : #'GToolkit-Nginx'
}

{ #category : #accessing }
NginxAccessLogFetcher >> accesLogLineParser [
	^ (#startOfLine asPParser,
  self ipParser,
  (' ' asPParser, '- ' asPParser plus) flatten,
  self dateParser,
  self getParser,
   String lf asPParser negate star flatten,
 String lf asPParser) star
]

{ #category : #accessing }
NginxAccessLogFetcher >> allAccesses [
	^ (self accesLogLineParser parse: log) collect: [:each | NginxAccess new datetime: each fourth; accessedURL: each fifth third]
]

{ #category : #accessing }
NginxAccessLogFetcher >> dateParser [
	|dateParser|
	dateParser := ($[ asPParser,
		#digit asPParser plus flatten,
		$/ asPParser,
		#letter asPParser plus flatten,
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
NginxAccessLogFetcher >> fetchAccessLog [
	log := ''.
OSSUnixSubprocess new
	command: 'ssh';
	arguments: {self sshServer . 'cat' . '/var/log/nginx/access.log'};
	redirectStdout;
	runAndWaitPollingEvery: (Delay forMilliseconds: 100) retrievingStreams: true onExitDo: [
		:process :outString  |
		log := outString.
	].
	^ log
]

{ #category : #accessing }
NginxAccessLogFetcher >> getParser [
	^((' "GET ' asPParser) optional,
	 (' "HEAD ' asPParser) optional,
	' ' asPParser negate plus flatten,
	' ' asPParser,
	'HTTP/1.1"' asPParser) 
]

{ #category : #accessing }
NginxAccessLogFetcher >> gtAllAccessesFor: aView [
	<gtView>
	|allAccesses|
	allAccesses := self allAccesses.
	allAccesses ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'All Accesses';
		priority: 3;
		items: [ allAccesses ];
		column: 'Time' item: [ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ] width: 240;
		column: 'Access' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem accessedURL ]
]

{ #category : #accessing }
NginxAccessLogFetcher >> gtZipAccessesFor: aView [
	<gtView>
	|allAccesses|
	allAccesses := self nonRootAccesses.
	allAccesses ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Zip Accesses';
		priority: 3;
		items: [ allAccesses ];
		column: 'Time' item: [ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ] width: 240;
		column: 'Access' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem accessedURL ]
]

{ #category : #accessing }
NginxAccessLogFetcher >> ipParser [
	^(#startOfLine asPParser, #digit asPParser plus flatten, (($. asPParser,#digit asPParser plus)) plus flatten ) flatten
]

{ #category : #accessing }
NginxAccessLogFetcher >> nonRootAccesses [
	^ self allAccesses select: [: each | each accessedURL endsWith:'zip']
]

{ #category : #accessing }
NginxAccessLogFetcher >> sshServer [
	^ sshServer
]

{ #category : #accessing }
NginxAccessLogFetcher >> sshServer: aSshServerString [
	sshServer := aSshServerString
]
