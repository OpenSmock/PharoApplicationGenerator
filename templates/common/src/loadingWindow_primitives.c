#include "pharovm/pharo.h"
#include "pharovm/pharoClient.h"
#include "pharovm/imageAccess.h"
#include "loading_window.h"

#include "pharovm/macros.h"
#include "pharovm/interpreter.h"

// these must be made static else they cause trouble with no-opt -O0 builds
// because the compiler doesn't inline them with -O0
static inline void primitiveEnd() {
    //pop all execept receiver, which will be answered (^self)
    pop(methodArgumentCount());
}

static inline void primitiveEndReturn(sqInt ret) {
    //pop all including receiver, we are answering our own result
    pop(methodArgumentCount() + 1);
    push(ret);
}

static inline void primitiveEndReturnInteger(sqInt ret) {
    pop(methodArgumentCount() + 1);
    pushInteger(ret);
}

Primitive(primitiveApplicationLoadingProgress){
	
	sqInt newPercentageOop;
	sqInt newPercentage;
	
	if(LOADING_BAR_SHOW){
		newPercentageOop = stackValue(0);
		newPercentage = integerValueOf(newPercentageOop);

		if(newPercentage < 0){
			newPercentage = LOADING_BAR_IMAGE_LOADING_PERCENTAGE;
		}else if(newPercentage > 100){
			newPercentage = 100;
		}else{
			newPercentage = LOADING_BAR_IMAGE_LOADING_PERCENTAGE + ((100 - LOADING_BAR_IMAGE_LOADING_PERCENTAGE) * newPercentage / 100); 
		}

		if(failed()){
			primitiveFail();
			return;
		}

		loading_window_setPercentage(newPercentage);
	}
	
	primitiveEnd();
}

Primitive(primitiveApplicationLoadingEnded){
	
	if(LOADING_BAR_SHOW){
		loading_window_destroy();
	}
	
	primitiveEnd();
}
