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
#include <curses.h>

int main(int argc, char **argv)
{
	wiimote_t wiimote = WIIMOTE_INIT;
	uint8_t data[6]={0,0,0,0,0,0};
	int nmotes=0;
	
	/* Print help information. */
	initscr();
	noecho();
	keypad ( stdscr, TRUE );
	
	printw("\nDiscovering Wiimote ....");
	printw("\n Home - Exit");
	printw("\nPress buttons 1 and 2 on the wiimote now to connect.");
	
  
	/* Discover at most 1 wiimote devices. */
	
	nmotes=wiimote_discover(&wiimote,1);
	if (nmotes<=0) {
		endwin();
		exit(1);
	}
	
	printw("Found : %s\n",wiimote.link.r_addr);
	
	if (wiimote_connect(&wiimote, wiimote.link.r_addr) < 0) {
	    fprintf(stderr, "unable to open wiimote: %s\n", wiimote_get_error());
	}
	else
		printw("\n Connected");
            
	/* Activate the first led on the wiimote. It will take effect on the
	   next call to wiimote_update. */

	wiimote.led.one  = 1;
	nunchuk_enable(&wiimote,0);
	wiimote_update(&wiimote);
	nunchuk_enable(&wiimote,1);
	
	
	while (wiimote_is_open(&wiimote)) {
				
		nunchuk_update(&wiimote);
                		
        // check for key strokes .. 
		switch ( getch() )
		{
		case KEY_UP:
		  printw ( "UP\n" );
		  wiimote_write_byte(&wiimote, 0x04a40001, 0x01);
		  break;
		case KEY_DOWN:
		  printw ( "DOWN\n" );
		  wiimote_write_byte(&wiimote, 0x04a40001, 0x02);
		  break;
		case KEY_LEFT:
		  printw ( "LEFT\n" );
		  wiimote_write_byte(&wiimote, 0x04a40001, 0x03);
		  break;
		case KEY_RIGHT:
		  printw ( "RIGHT\n" );
		  wiimote_write_byte(&wiimote, 0x04a40001, 0x04);
		  break;
		case 'e':
		  endwin();
		  exit(0);
		  break;
		}

	   usleep(20000);
	
		printw("Byte 0=%03d 1=%03d 2=%03d 3=%03d 4=%03d 5=%d 6=%d\n", 
			wiimote.ext.nunchuk.joyx,
			wiimote.ext.nunchuk.joyy,
			wiimote.ext.nunchuk.axis.x,
			wiimote.ext.nunchuk.axis.y,
			wiimote.ext.nunchuk.axis.z,
			wiimote.ext.nunchuk.keys.z,
			wiimote.ext.nunchuk.keys.c);
		printw("\n");
		
		refresh();
	}		
	endwin();
	return 0;
}

