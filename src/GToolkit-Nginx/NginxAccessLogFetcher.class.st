Class {
	#name : #NginxAccessLogFetcher,
	#superclass : #Object,
	#instVars : [
		'sshServer',
		'log',
		'allAccesses'
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

 String lf asPParser) optimize 
]

{ #category : #accessing }
NginxAccessLogFetcher >> agentParser [
^ ( 
	String lf asPParser negate plus flatten
	
	)
]

{ #category : #accessing }
NginxAccessLogFetcher >> allAccesses [
	| parser |
	allAccesses ifNil: [
		self fetchAccessLog.
		parser := self accesLogLineParser.
		allAccesses := (self  log lines collect: [:l | 
			NginxAccess new 
				parser: parser;
				log: (l,String lf);
				parsed
				])].
	^ allAccesses
]

{ #category : #accessing }
NginxAccessLogFetcher >> allAccesses: anArray [
	allAccesses := anArray
]

{ #category : #accessing }
NginxAccessLogFetcher >> allGtZipDownloads [
	| accesses |
	accesses := self allAccesses select: [: each | (each accessedURL findString: '/gt/') > 0].
	accesses := accesses select: [: each | (each accessedURL findString: '.zip') > 0].
	^ accesses
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
	| proc fileLogNames filesContents entireLog |
	
	proc := (GtUnixSubprocess command: 'rm' arguments: #('-rf' 'nginx')).
	proc errorBlock: [ :p | self error: 'External process failed, see proc' ].
	proc runAndWait.
	proc stdout.
	proc := (GtUnixSubprocess 
		command: 'scp' 
		arguments: {'-r' . (self sshServer, ':/var/log/nginx') . '.'}).
	proc errorBlock: [ :p | self error: 'External process failed, see proc' ].
	proc runAndWait.
	proc stdout.
	proc := (GtUnixSubprocess command: 'gzip' arguments: #('-d' 'nginx/access.log.10.gz' 'nginx/access.log.11.gz' 'nginx/access.log.12.gz' 'nginx/access.log.13.gz' 'nginx/access.log.14.gz' 'nginx/access.log.2.gz'  'nginx/access.log.3.gz'  'nginx/access.log.4.gz'  'nginx/access.log.5.gz'  'nginx/access.log.6.gz'  'nginx/access.log.7.gz'  'nginx/access.log.8.gz'  'nginx/access.log.9.gz')).
	proc errorBlock: [ :p | self error: 'External process failed, see proc' ].
	proc runAndWait.
	proc stdout.
	fileLogNames := (1 to: 14) collect:[:digit | 'nginx/access.log.', digit asString ].
	filesContents := fileLogNames collect: [:f | f asFileReference readStreamDo: [ :stream | 
		| result |
		result := [stream contents ]
			on: Error 
			do: [ (stream binary next: 10000) asString ]]].
	entireLog := filesContents fold: [:a :b | a,b].
	log := entireLog.
	^ entireLog
]

{ #category : #accessing }
NginxAccessLogFetcher >> getParser [
	^((' "' asPParser),
	  '"' asPParser negate star flatten,
	  ('"' asPParser) ) 
]

{ #category : #accessing }
NginxAccessLogFetcher >> gtAllAccessesFor: aView [
	<gtView>
	| accesses |
	accesses := self allAccesses.
	accesses ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'All Accesses';
		priority: 3;
		items: [ allAccesses ];
		column: 'Time'
			item:
				[ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ]
			width: 180;
		column: 'Access'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem accessedURL ];
		column: 'Channel'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem channel ];
		column: 'Agent'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem agent ]
]

{ #category : #accessing }
NginxAccessLogFetcher >> gtZipAccessesFor: aView [
	<gtView>
	| accesses |
	accesses := self allGtZipDownloads.
	accesses ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'GT Accesses';
		priority: 3;
		items: [ accesses ];
		column: 'Time'
			item:
				[ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ]
			width: 170;
		column: 'Access'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem accessedURL ];
			
		column: 'Agent'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem agent ] width: 100;
		column: 'Channel'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem channel ] width: 100
]

{ #category : #accessing }
NginxAccessLogFetcher >> ipParser [
	^(#startOfLine asPParser, #digit asPParser plus flatten, (($. asPParser,#digit asPParser plus)) plus flatten ) flatten
]

{ #category : #accessing }
NginxAccessLogFetcher >> log [
 ^ log
]

{ #category : #accessing }
NginxAccessLogFetcher >> nonRootAccesses [
	^ self allAccesses select: [: each | (each accessedURL findString: '/gt/') > 0]
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
