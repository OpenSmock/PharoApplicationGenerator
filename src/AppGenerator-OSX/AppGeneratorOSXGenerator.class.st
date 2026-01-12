Class {
	#name : 'AppGeneratorOSXGenerator',
	#superclass : 'AppGeneratorAbstractGenerator',
	#category : 'AppGenerator-OSX',
	#package : 'AppGenerator-OSX'
}

{ #category : 'copying' }
AppGeneratorOSXGenerator >> copyIconSetIn: appDirectory [ 
	
	(appDirectory / 'Contents' / 'Resources') ensureCreateDirectory.
	
	(appDirectory / 'Contents' / 'Resources' / 'icon.icns') ensureDelete.
	self iconSetFile copyTo: (appDirectory / 'Contents' / 'Resources' / 'icon.icns').
	
	"Copying in the Build directory for the installer icon"
	(outputDirectory / 'installer.icns') ensureDelete.
	self iconSetFile copyTo: (outputDirectory / 'installer.icns')
	
]

{ #category : 'copying' }
AppGeneratorOSXGenerator >> copyIncludes [

	| includeDir |
	
	includeDir := outputDirectory / 'include'.
	includeDir ensureCreateDirectory.
	
	self 
		copy: self templateDirectory / 'include' / 'loading_window.h' 
		to: includeDir / 'loading_window.h'.

	self 
		copyTemplate: self templateDirectory / 'include' / 'loading_window_config.h.template' 
		to: includeDir / 'loading_window_config.h'.
]

{ #category : 'copying' }
AppGeneratorOSXGenerator >> copyInstallerBackground [
	
	| dst |
	dst := outputDirectory / 'installer-background.png'.	
	dst ensureDelete.
	(properties at: #InstallerBackgroundFile) copyTo: dst 
]

{ #category : 'copying' }
AppGeneratorOSXGenerator >> copySources [

	| srcDir templateSrc |

	templateSrc := self templateDirectory / 'src'.
	srcDir := outputDirectory / 'src'.
	srcDir ensureCreateDirectory.

	self
		copyTemplate: templateSrc / 'main.c.template'
		to: srcDir / 'main.c'.
		
	self copy: templateSrc / 'loadingWindow.c'
		to: srcDir / 'loadingWindow.c'.

	self copy: templateSrc / 'loadingWindow_primitives.c'
		to: srcDir / 'loadingWindow_primitives.c'.
	
	self copy: templateSrc / 'loadingWindow.m'
		to: srcDir / 'loadingWindow.m'.

]

{ #category : 'external resources' }
AppGeneratorOSXGenerator >> externalResourceTargetDirectory [

	^ outputDirectory / (self appName , '.app') / 'Contents'
	  / 'Resources'
]

{ #category : 'utilities' }
AppGeneratorOSXGenerator >> fillWithDefaults [

	super fillWithDefaults.

	properties at: #BundleIdentifier ifAbsentPut: 'org.pharo.example'.
	properties
		at: #IconSetFile
		ifAbsentPut: self templateDirectory / 'icon.icns'.
	properties
		at: #InstallerBackgroundFile
		ifAbsentPut: self templateDirectory / 'installer-background.png'.
]

{ #category : 'translating' }
AppGeneratorOSXGenerator >> generate [
	
	| appDirectory |
	
	super generate.

	"Build App directory"
	appDirectory := outputDirectory / (self appName , '.app').
	appDirectory ensureCreateDirectory.
		
	self copyIconSetIn: appDirectory. 
	self generatePListIn: appDirectory.

	self 
		copyInstallerBackground;
		copySources;
		copyIncludes.
	
	self 
		generateBuildScript;
		generateCMakeScript
]

{ #category : 'generating' }
AppGeneratorOSXGenerator >> generateBuildScript [

	self
		copyTemplate: self templateDirectory / 'build.sh.template'
		to: outputDirectory / 'build.sh'
]

{ #category : 'generation' }
AppGeneratorOSXGenerator >> generateCMakeScript [

	self
		copyTemplate: self templateDirectory / 'CMakeLists.txt.template'
		to: outputDirectory / 'CMakeLists.txt'
]

{ #category : 'generating' }
AppGeneratorOSXGenerator >> generatePListIn: appDirectory [

	(appDirectory / 'Contents') ensureCreateDirectory.
	self
		copyTemplate: self templateDirectory / 'Info.plist.template'
		to: appDirectory / 'Contents' / 'Info.plist'
]

{ #category : 'generating' }
AppGeneratorOSXGenerator >> generateParametersString [

	| stream collection |
	collection := (properties at: #Parameters) asOrderedCollection.

	stream := WriteStream on: String crlf.
	collection do: [ :each |
			stream
				nextPut: Character tab;
				nextPut: Character tab;
				nextPutAll: '<string>';
				nextPutAll: each asString;
				nextPutAll: '</string>';
				nextPut: Character cr ].
	properties at: #Parameters put: stream contents
]

{ #category : 'accessing' }
AppGeneratorOSXGenerator >> iconSetFile [
	
	^ properties at: #IconSetFile 
]

{ #category : 'accessing' }
AppGeneratorOSXGenerator >> platformName [

	^ 'Darwin'
]
