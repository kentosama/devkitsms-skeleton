#include "SMSlib.h"
#include "types.h"

int main()
{
	SMS_displayOn();

	while(TRUE)
	{
		SMS_waitForVBlank();
	}
}
