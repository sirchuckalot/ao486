#
#  Makefile for building the Zet BIOS in Linux
#  Copyright (C) 2010  Zeus Gomez Marmolejo <zeus@aluzina.org>
#  Copyright (C) 2010  Donna Polehn <dpolehn@verizon.net>
#
#  This file is part of the Zet processor. This program is free software;
#  you can redistribute it and/or modify it under the terms of the GNU
#  General Public License as published by the Free Software Foundation;
#  either version 3, or (at your option) any later version.
#
#  Zet is distrubuted in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
#  License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Zet; see the file COPYING. If not, see
#  <http://www.gnu.org/licenses/>.
#

#
#  ZET BIOS BUILD MAKE - Linux version - 10-10-2010
#  ----------------------------------------------------------------------------
#
#  This is the make file for the Zet Rom BIOS and VGA BIOS Builds.
#  To build it, you will need the Open Watcom compiler. If you have
#  it installed on your machine, then you should be able to just type
#  wmake and watcom should build it. There will be a small number of warning
#  messages, this is normal.
#

# File extension in Linux
O = .o
E =

# Current directory (for executing programs)
CDIR = ./

all: mon88.rom

!include "common.inc"


clean:
	rm -f *.dat *.hex *.o *.obj *.sym *.rom *.exe *.err *.map

#
#  End of make.
#
