#include "memory_access.h"




/***************************************************************************************************
*
* Function Name : memoryRead32
* Description   : Single 32 bit location memory read and display.   
* Parameters    : Address to read from   
* Returns       : Status 
*
***************************************************************************************************/
void memoryRead32(int address)
{

int addr, data;

  addr = address & ~3;  // ensure read address is aligned to a 32 bit word boundary 
    data = *(int *)addr;
    xil_printf("0x%08x\n", data);//("0x%08x\n", data);

   return data ;
}


/***************************************************************************************************
*
* Function Name : memRead32
* Description   : Single 32 bit location memory read and display.
* Parameters    : Address to read from
* Returns       : Data
*
***************************************************************************************************/
int memRead32(int address)
{

int addr, data;

  addr = address & ~3;  // ensure read address is aligned to a 32 bit word boundary
    data = *(int *)addr;
   return data ;
}




/***************************************************************************************************
*
* Function Name : memoryWrite32
* Description   : Single 32 bit location memory write.   
* Parameters    : Address to write to
*                 32 bit data to write    
* Returns       : Status 
*
***************************************************************************************************/
void memoryWrite32(int address, int data)
{

int addr;

  addr = address & ~3;  // ensure write address is aligned to a 32 bit word boundary 
    *(int *)addr = data;

   return;
}
