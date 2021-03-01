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
	parser := self accesLogLineParser.
	^ (self  log lines collect: [:l | parser parse: (l,String lf)]) 
		collect: 
		[:each | NginxAccess new 
			datetime: each fourth;
			accessedURL: each fifth second;
			channel: (each at: 11) second;
			agent: (each at: 13) second]
	"^ (self log lines select: [:l | (parser parse: (l,String lf)) isArray not]) "
		"select: [:each | each isArray not]"
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
	| allAccesses |
	allAccesses := self allAccesses.
	allAccesses ifNil: [ ^ aView empty ].
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
	| allAccesses |
	allAccesses := self nonRootAccesses.
	allAccesses ifNil: [ ^ aView empty ].
	^ aView columnedList
		title: 'Zip Accesses';
		priority: 3;
		items: [ allAccesses ];
		column: 'Time'
			item:
				[ :eachItem :eachIndex | eachItem datetime asRopedText foreground: Color gray ]
			width: 170;
		column: 'Access'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem accessedURL ];
		column: 'Agent'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem agent ];
		column: 'Channel'
			item: [ :eachItem :eachIndex | eachItem ]
			text: [ :eachItem | eachItem channel ]
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
