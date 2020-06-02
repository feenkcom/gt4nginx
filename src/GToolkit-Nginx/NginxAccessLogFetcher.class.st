Class {
	#name : #NginxAccessLogFetcher,
	#superclass : #Object,
	#instVars : [
		'sshServer'
	],
	#category : #'GToolkit-Nginx'
}

{ #category : #accessing }
NginxAccessLogFetcher >> fetchAccessLog [
	|log|
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
NginxAccessLogFetcher >> sshServer [
	^ sshServer
]

{ #category : #accessing }
NginxAccessLogFetcher >> sshServer: aSshServerString [
	sshServer := aSshServerString
]
