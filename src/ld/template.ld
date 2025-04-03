MEMORY
{
  FLASH (rx) : ORIGIN = 0x00000000, LENGTH = __FLASH_SIZE__
  RAM   (xrw) : ORIGIN = 0x20000000, LENGTH = __RAM_SIZE__
}

SECTIONS
{
  .init :
  {
    KEEP(*(.init*))
  } > FLASH

  .text :
  {
     *(.text*)
  } > FLASH

  .rodata :
  {
     *(.srodata*)
     *(.rodata*)
  } > FLASH

  .data :
  {
     __data_start = .;
     *(.sdata*)
     *(.data*)
     __data_end = .;
  } > RAM AT> FLASH

  .bss (NOLOAD) :
  {
      __bss_start = .;
      *(.bss*)
      *(.sbss*)
      __bss_end = .;
  } > RAM

  __data_load_start = LOADADDR(.data);
  __start_of_ram = ORIGIN(RAM);
  __end_of_stack = ORIGIN(RAM) + LENGTH(RAM);
  PROVIDE(__global_pointer$ = __data_start + 0x800);
}
