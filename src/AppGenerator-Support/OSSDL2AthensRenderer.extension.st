Extension { #name : 'OSSDL2AthensRenderer' }

{ #category : '*AppGenerator-Support' }
OSSDL2AthensRenderer >> prepareForDrawing [
	mutex critical: [
		athensSurface deviceScale: (renderer outputExtent / backendWindow extent).
		textureExtent ~= renderer outputExtent ifTrue: [ self resized ].
	]
]
