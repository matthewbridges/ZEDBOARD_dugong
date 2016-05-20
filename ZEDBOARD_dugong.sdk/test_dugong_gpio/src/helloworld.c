/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

#include "xil_io.h"

int main()
{
	init_platform();

	print("Hello World\n\r");

	uint x = 0xFFFFFFFF;
	INTPTR Addr = 0x88000000;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = Addr + 4;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = Addr + 4;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = Addr + 4;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = Addr + 4;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = Addr + 4;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = Addr + 4;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = Addr + 4;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = 0x88000010;
	x = 0xFF;
	Xil_Out32(Addr, (u32) x);

	Addr = 0x88000018;
	x = 0xFF;
	Xil_Out32(Addr, (u32) x);

	Addr = 0x8800001C;
	x = 0x0;
	Xil_Out32(Addr, (u32) x);

	Addr = 0x88000010;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = 0x88000018;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = 0x8800001C;

	x = (uint) Xil_In32(Addr);

	printf("Value at 0x%08x is 0x%08x:\n", (uint) Addr, x);

	Addr = 0x88000018;
	x = 0x0;

	INTPTR Addr_z = 0x88000034;
	uint z = 1;

	uint y;

	uint i, j, k;

	uint b = 0;

	i = 0;
	j = 0;
	k = 0;

	while (1) {
		i++;
		k++;

		if (i == 1000) {
			i = 0;
			j++;
			if (j > 100) {
				y = 0xFF;
				j = 0;
				Xil_Out32(Addr, (u32) (x & y));
			}
			if (j > (b/100)) {
				y = 0x00;
				Xil_Out32(Addr, (u32) (x & y));
			}
		}

		if (k == 3000000) {
			k = 0;

			z = (uint) Xil_In32(Addr_z);

			b = b + z;

			if (b > 3000) {
				b = 1;
			}

			if (x == 0) {
				x = 0x22222200;
				x = 0xFF;
			} else {
				x = x >> 1;
			}

		}
	}

	cleanup_platform();
	return 0;
}
