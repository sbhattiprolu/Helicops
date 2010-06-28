/* $Id: test1.c 16 2007-01-22 21:51:27Z bja $ 
 *
 * Copyright (C) 2007, Joel Andersson <bja@kth.se>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>;
#include "wiimote.h"
#include "wiimote_api.h"

int main(int argc, char **argv)
{
	wiimote_t wiimote = WIIMOTE_INIT;
	uint8_t data[6]={0,0,0,0,0,0};
	
	if (argc < 2) {
		fprintf(stderr, "Usage: test1 BDADDR\n");
		exit(1);
	}
	
	/* Print help information. */
	
	printf("test1 - libwiimote test application\n\n");
	printf(" Home - Exit\n\n");
	printf("Press buttons 1 and 2 on the wiimote now to connect.\n");
	
	/* Connect the wiimote specified on the command line. */
	
	if (wiimote_connect(&wiimote, argv[1]) < 0) {
		fprintf(stderr, "unable to open wiimote: %s\n", wiimote_get_error());
		exit(1);
	}

	/* Activate the first led on the wiimote. It will take effect on the
	   next call to wiimote_update. */

	wiimote.led.one  = 1;
	nunchuk_enable(&wiimote,0);
	wiimote_update(&wiimote);
	nunchuk_enable(&wiimote,1);
	
	while (wiimote_is_open(&wiimote)) {
		
		/* The wiimote_update function is used to synchronize the wiimote
		   object with the real wiimote. It should be called as often as
		   possible in order to minimize latency. */
		
		//if (wiimote_update(&wiimote) < 0) {
		//	wiimote_disconnect(&wiimote);
		//	break;
		//}
		
		
		nunchuk_update(&wiimote);
                		
        // Send some data to the arduino
        wiimote_write_byte(&wiimote, 0x04a40001, 0x01);
        wiimote_write_byte(&wiimote, 0x04a40002, 0x02);
        wiimote_write_byte(&wiimote, 0x04a40003, 0x03);
        wiimote_write_byte(&wiimote, 0x04a40004, 0x04);
        wiimote_write_byte(&wiimote, 0x04a40005, 0x05);
        wiimote_write_byte(&wiimote, 0x04a40006, 0x06);
        wiimote_write_byte(&wiimote, 0x04a40007, 0x07);
        wiimote_write_byte(&wiimote, 0x04a40008, 0x08);
        wiimote_write_byte(&wiimote, 0x04a40009, 0x09);
        wiimote_write_byte(&wiimote, 0x04a4000A, 0x0A);
        wiimote_write_byte(&wiimote, 0x04a4000B, 0x0B);
        wiimote_write_byte(&wiimote, 0x04a4000C, 0x0C);
        wiimote_write_byte(&wiimote, 0x04a4000D, 0x0D);
        wiimote_write_byte(&wiimote, 0x04a4000E, 0x0E);
        wiimote_write_byte(&wiimote, 0x04a4000F, 0x0F);
	sleep(1);
	//wiimote_read(&wiimote,0x04a400FA,data,6);
		fprintf(stderr, "Byte 0=%03d 1=%03d 2=%03d 3=%03d 4=%03d 5=%d 6=%d\n", 
			wiimote.ext.nunchuk.joyx,
			wiimote.ext.nunchuk.joyy,
			wiimote.ext.nunchuk.axis.x,
			wiimote.ext.nunchuk.axis.y,
			wiimote.ext.nunchuk.axis.z,
			wiimote.ext.nunchuk.keys.z,
			wiimote.ext.nunchuk.keys.c);
		fprintf(stderr, "\n");
	}		
	return 0;
}

