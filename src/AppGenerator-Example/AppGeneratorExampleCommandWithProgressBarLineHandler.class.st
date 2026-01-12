Class {
	#name : 'AppGeneratorExampleCommandWithProgressBarLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'AppGenerator-Example',
	#package : 'AppGenerator-Example'
}

{ #category : 'accessing' }
AppGeneratorExampleCommandWithProgressBarLineHandler class >> commandName [

	^ 'appGeneratorExampleWithProgressBar'
]

{ #category : 'activation' }
AppGeneratorExampleCommandWithProgressBarLineHandler >> activate [

	0 to: 100 by: 5 do: [ :i |
		self applicationLoadingProgress: i.
		0.5 second wait ].
	
	OSWindowDriver current startUp: true.
	
	AppGeneratorSupport errorHandler: AppGeneratorSDLMessageErrorHandler new.
	SDL2AthensDrawingExample new open.
	
	self applicationLoadingEnded.
]

{ #category : 'activation' }
AppGeneratorExampleCommandWithProgressBarLineHandler >> applicationLoadingEnded [

	<primitive: primitiveApplicationLoadingEnded>
	
	self primitiveFailed
]

{ #category : 'activation' }
AppGeneratorExampleCommandWithProgressBarLineHandler >> applicationLoadingProgress: aValue [

	<primitive: primitiveApplicationLoadingProgress>
	
	self primitiveFailed
]
