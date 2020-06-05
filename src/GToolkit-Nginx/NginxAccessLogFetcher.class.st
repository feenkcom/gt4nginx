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
  (' ' asPParser, '- ' asPParser, ' ' asPParser negate plus, ' ' asPParser ) flatten,
  self dateParser,
  self getParser,
  ' ' asPParser,
  self responseCodeParser,
  ' ' asPParser,
  self responseTimeParser,
  ' ' asPParser,
  self channelParser,
  ' ' asPParser,
  self agentParser,

 String lf asPParser) star
]

{ #category : #accessing }
NginxAccessLogFetcher >> agentParser [
^ ( '"' asPParser,
	'"' asPParser negate plus flatten,
	'"' asPParser
	)
]

{ #category : #accessing }
NginxAccessLogFetcher >> allAccesses [
	^ (self accesLogLineParser parse: log) collect: 
		[:each | NginxAccess new 
			datetime: each fourth;
			accessedURL: each fifth second;
			channel: (each at: 11) second;
			agent: (each at: 13) second]
]

{ #category : #accessing }
NginxAccessLogFetcher >> channelParser [
	^ ( '"' asPParser,
	'"' asPParser negate plus flatten,
	'"' asPParser
	)
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
	^((' "GET ' asPParser) | (' "POST ' asPParser)  |  (' "HEAD ' asPParser) | (' "PATCH ' asPParser),
	  ' ' asPParser negate plus flatten,
	  ' ' asPParser,
	  ('HTTP/1.1"' asPParser) optional,
	  ('HTTP/1.0"' asPParser) optional) 
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
		column: 'Time' item: [ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ] width: 180;
		column: 'Access' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem accessedURL  ];
		column: 'Channel' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem channel ];
		column: 'Agent' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem agent ]
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
		column: 'Time' item: [ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ] width: 170;
		column: 'Access' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem accessedURL ];
		column: 'Agent' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem agent ];
				column: 'Channel' item: [ :eachItem :eachIndex | eachItem ] format: [ :eachItem | eachItem channel ]

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
NginxAccessLogFetcher >> responseCodeParser [
	^ #digit asPParser plus flatten
]

{ #category : #accessing }
NginxAccessLogFetcher >> responseTimeParser [
	^ #digit asPParser plus flatten
]

{ #category : #accessing }
NginxAccessLogFetcher >> sshServer [
	^ sshServer
]

{ #category : #accessing }
NginxAccessLogFetcher >> sshServer: aSshServerString [
	sshServer := aSshServerString
]
