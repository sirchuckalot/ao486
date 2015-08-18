//--------------------------------------------------------------------------------------
// UPLOAD
//
// Description
//    - Simple Serial Upload/Terminal program for CPU86.
//    - (c) HT-LAB 2005
//
// Comments
//    - Compile using Watcom's wcl.exe
//    - Execute in a good old DOS box
//	  - CPU86 VHDL IP core can be downloaded from www.ht-lab.com
//	  
//--------------------------------------------------------------------------------------
//
// Copyright (C) 2005 Hans Tiggeler - http://www.ht-lab.com
// Send comments and bugs to : cpu86@ht-lab.com
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or    
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software Foundation,
// Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//--------------------------------------------------------------------------------------
// Version 0.1  02/07/05 Created Hans Tiggeler  
//--------------------------------------------------------------------------------------

#include <dos.h>
#include <i86.h>
#include <stdio.h>
#include <conio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define F1_KEY          0x3B
#define F2_KEY          0x3C
#define FILE_EXTENTION  ".HEX"          // Default file extension


#define USER_ESC        1               // User pressed ESC/F1
#define RX_OVERFLOW     2               // RX Buffer Overflow Error
                                                                
#define COMPORT         0x3F8           // COM1 0x3F8,COM2 0x2F8,COM3 0x3E8,COM4 0x2E8                      
#define INTVECT         0x0C            // Com Port's IRQ  

#define MAX_FILENAME    80
#define FALSE           0
#define TRUE            !FALSE
#define ESC             27
#define MAX_WORD        120   
#define MAX_LINE        512   
#define MAX_BUFFER      4096            // Receive buffer


int     debug=0;                        // 0=Debug off
int     cominit=0;                      // set if comport has been initialised
char    rxbuffer[MAX_BUFFER];           // Receive buffer
int     cnt=0;                          // counter used for full/empty
int     rdptr=0;                        // Read Pointer
int     wrptr=0;                        // Write Pointer
int     errstat=0;                      // Global error status

void    getline(FILE *fp, char *word);
void    init_comport(void);
void    txbyte(unsigned char c);
int     upload_file(char *filename);
int     rxbyte (unsigned char *c);


void __interrupt __far (*old_int_handler)();// Store original int vector

void __interrupt __far int_handler() {  // receive serial port int handler 

    int c;
    do { 
        if ((c=inp(COMPORT+5))&1) {     // Character available?
            //putch(inp(COMPORT));      // Fails, DOS is not re-entrant
            if (cnt==MAX_BUFFER) {
                errstat=RX_OVERFLOW;
            } else {
                rxbuffer[wrptr]=inp(COMPORT);   // Simple FIFO
                wrptr=(wrptr+1)%MAX_BUFFER;
                cnt++;
            }
        }
    } while (c&1 && !errstat);          // More char pending?
    outp(0x20,0x20);                    // 8259 EOI 
}


int main(int argc, char * argv[])
{
    int  c;
    int  n;   
    char filename[MAX_FILENAME]="";
    int  term=FALSE;                    // Enter terminal mode after load

    if (argc<2) {
        printf("\nUsage   : UpLoad {<filename>} {-t}");
        printf("\nExample : UpLoad mon88.hex -t");
        printf("\nExample : UpLoad -t");
        return 1;
    }
    printf("UpLoad ver 0.1 (c) HT-LAB 2005\n");
    
    init_comport();                     // Setup comport 38400,N,8,1

    if ((argc==2 && strcmp(argv[1],"-t")==0) || 
        (argc==3 && strcmp(argv[2],"-t")==0)) term=TRUE;

    if (strcmp(argv[1],"-t")!=0) {
        strncpy(filename,argv[1],MAX_FILENAME);    // copy argument into filename
        if (!strchr(filename, '.')) strcat(filename,FILE_EXTENTION);
        errstat=upload_file(filename);  
    }
    if (!errstat && term) {
        printf("\n\nTerminal mode (F1 to exit, F2 to upload file)\n");

        while (!errstat) {
            if (kbhit()){
                if ((c=getch())==0){            // Any function key pressed?
                    switch (c=getch()){
                        case F1_KEY : 
                            errstat=USER_ESC;
                            break;       
                        case F2_KEY :
                            printf("\nEnter filename :");scanf("%s",filename);
                            if (!strchr(filename,'.')) strcat(filename,FILE_EXTENTION);
                            upload_file(filename);
                            break;
                        default: printf("\nPress F1 to quite, F2 to upload file");
                    }                   
                } else txbyte(c);
            }
            
            if (cnt!=0 && !errstat) {
                putch(rxbuffer[rdptr]);
                rdptr=(rdptr+1)%MAX_BUFFER;
                cnt--;
            } else delay(100);  // bodge, need to change to proper int handler.
        }
        
    }
    delay(500);     // wait before killing the comport, some txchar might
                    // still be pending
    release_comport();
    if (errstat&0xFE) printf("\nExit with error %d",errstat); 
            else printf("\nDone..\n");
    return errstat;
}

int upload_file(char *filename)
{
    int  loadok=TRUE;
    int  timeout=FALSE;
    char line[MAX_LINE]="";
    time_t seconds;
    char c;
    int  n;
    FILE *fp=NULL;                      // pointer to input file

    if ((fp=fopen(filename,"rt"))==NULL) {
        fprintf(stderr, "\nCannot open file : %s.\n",filename);
        return 1;
    }

    txbyte('L');                        // Transmit it Load command to MON88
    delay(100);                         // Wait for mon88 to display some info string

    while (rxbyte(&c)) {                // Clear rx buffer
        putch(c);
        if (kbhit()){
            if ((c=getch())==ESC) errstat=USER_ESC;
            else if (c==0 && getch()==F1_KEY) errstat=USER_ESC;
        }
    }

    while (!feof(fp) && !errstat) {     // Process each line
        getline(fp,line);               // Read single line from input file
        
        loadok=FALSE;
        while (!loadok && !errstat) {

            if (line[0]==':') {
                
                printf("\nUpLoad %s",line);
                for (n=0;n<strlen(line);n++) {
                    txbyte(line[n]);    // Transmit it
                }

                if ((line[8]!='3') && (line[8]!='1')) { // Not EOF or Execute record
                    
                    seconds=time(NULL)+1;   // Start Timer
                    timeout=FALSE;
                    while ( rxbyte(&c)==0 && !timeout){ // Wait for ack character '.'
                        if (seconds<time(NULL)) timeout=TRUE;
                    }
                    if (!timeout) {
                        if (c=='.') {
                            loadok=TRUE;
                            printf(" ok");
                        } else printf(" Retry");
                    } else printf(" Retry");
                    if (kbhit()){
                        if (getch()==ESC) errstat=USER_ESC;
                        else if (c==0 && getch()==F1_KEY) errstat=USER_ESC;
                    }
                        
                } else {
                    printf(" EOF/EXEC");
                    loadok=TRUE;
                }
            } else loadok=TRUE;         
        }           
    }
    fclose(fp);
    return errstat;
}

int rxbyte (char *c)
{
    if (cnt!=0) {
        *c=rxbuffer[rdptr];
        rdptr=(rdptr+1)%MAX_BUFFER;         // Add to RX Fifo
        cnt--;
        return 1;
    } else return 0;
}

void txbyte(unsigned char c)
{
    int i;
    while ((inp(COMPORT+5) & 0x40) == 0);   // Wait TX Ready
    outp(COMPORT, c);                       // Transmit character
}

void getline(FILE *fp, char *word)
{
    char c;
    int endword=FALSE;

    while (!endword && !feof(fp)) {
        if ((c=fgetc(fp))!='\n') {
            *word++=c;
        } else endword=TRUE;
    } // while
    *word='\0';                             // terminate string
}

void init_comport(void) {

    if (!cominit) {                         // check if comport is not already init
        old_int_handler=_dos_getvect(INTVECT);// Save old Interrupt Vector
        outp(COMPORT+1, 0);                 // Turn off interrupts - COMPORT
        _disable();                         // install new interrupt handler
        _dos_setvect(INTVECT, int_handler); // Set Interrupt Vector Entry
        _enable();
        cominit=1;                          // comport is initialised
    }

    outp(COMPORT+1, 0);                     // Disable comport int
    outp(COMPORT+3, 0x80);                  // SET DLAB ON 
                                            // 0x01 = 115,200 BPS 
                                            // 0x02 =  57,600 BPS 
                                            // 0x03 =  38,400 BPS 
                                            // 0x06 =  19,200 BPS 
                                            // 0x0C =   9,600 BPS 
    outp(COMPORT+0, 0x03);                  // Set Baud rate - Divisor Latch Low Byte 
    outp(COMPORT+1, 0x00);                  // Set Baud rate - Divisor Latch High Byte 
    outp(COMPORT+3, 0x03);                  // 8 Bits, No Parity, 1 Stop Bit 
    outp(COMPORT+2, 0xC7);                  // FIFO Control Register 
    outp(COMPORT+4, 0x0B);                  // Turn on DTR, RTS, and OUT2 

    outp(0x21,(inp(0x21) & 0xEF));          // Set PIC
    outp(COMPORT+1 , 0x01);                 // Interrupt when data received 
}

void release_comport(void)                  // Restore int handler and disable comport
{
    if (cominit) {                          // check if comport is initialised
        outp(COMPORT+1 , 0);                // Turn off interrupts - COMPORT 
        outp(0x21,(inp(0x21) | 0x10));      // MASK IRQ using PIC 
                                            // COM1 (IRQ4) - 0x10  
                                            // COM2 (IRQ3) - 0x08  
                                            // COM3 (IRQ4) - 0x10  
                                            // COM4 (IRQ3) - 0x08  
        _disable();                         // disable interrupts
        _dos_setvect(INTVECT,old_int_handler);// Restore old interrupt vector
        _enable();                          // reenable interrupts
        cominit=0;
    }
}
