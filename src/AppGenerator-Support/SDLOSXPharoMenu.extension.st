Extension { #name : 'SDLOSXPharoMenu' }

{ #category : '*AppGenerator-Support' }
SDLOSXPharoMenu >> addServicesMenuTo: aNSMenu [

	| selServicesMenu servicesMenu sharedApplication selSetServicesMenu |
	selServicesMenu := ObjCLibrary uniqueInstance lookupSelector: 'servicesMenu'.
	sharedApplication := ObjCLibrary uniqueInstance sharedApplication.
	servicesMenu := ObjCLibrary uniqueInstance sendMessage: selServicesMenu to: sharedApplication.
	selSetServicesMenu := ObjCLibrary uniqueInstance lookupSelector: 'setServicesMenu:'.

	"We always generate a new service menu, as it can be already put elsewhere. So we don't need to ask"
	servicesMenu := self newNSMenu.
	ObjCLibrary uniqueInstance sendMessage: selSetServicesMenu to: sharedApplication  withPointer: servicesMenu.

	self addMenuItemTo: aNSMenu title: 'Services' withSubMenu: servicesMenu.
	self addSeparatorTo: aNSMenu

]
