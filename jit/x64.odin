package leaf_jit


X64_RET :: 0xC3


Operand_Kind :: enum u8 {
  Register = 1,
}

Operand :: struct {

}

Mod_Kind :: enum u8 {
  None      = 0b00,
  S8        = 0b01,
  S32       = 0b10,
  Register  = 0b11,
}

Register_Index :: enum u8 {
  AX = 0b000,
  CX = 0b001,
  DX = 0b010,
  BX = 0b011,
  SP = 0b100,
  BP = 0b101,
  SI = 0b110,
  DI = 0b111,
}

REX_PREFIX :: 0b0100
Rex_Byte :: bit_field u8 {
  prefix: u8 | 4,
  w: bool | 1,
  r: bool | 1,
  x: bool | 1,
  b: bool | 1,
}
