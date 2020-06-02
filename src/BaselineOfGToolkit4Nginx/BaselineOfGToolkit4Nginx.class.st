Class {
	#name : #BaselineOfGToolkit4Nginx,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Nginx
}

{ #category : #baselines }
BaselineOfGToolkit4Nginx >> baseline: spec [
	<baseline>
	spec
		for: #common do: [
			spec
				package: 'GToolkit-Nginx' ]
]
