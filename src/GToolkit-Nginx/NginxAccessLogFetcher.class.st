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
	"^ self accesLogLineParser parse: log"
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
NginxAccessLogFetcher >> ipParser [
	^(#startOfLine asPParser, #digit asPParser plus flatten, (($. asPParser,#digit asPParser plus)) plus flatten ) flatten
]

{ #category : #accessing }
NginxAccessLogFetcher >> sshServer [
	^ sshServer
]

{ #category : #accessing }
NginxAccessLogFetcher >> sshServer: aSshServerString [
	sshServer := aSshServerString
]
