package leaf_jit

// import "core:fmt" // remove
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

Register_Kind :: enum u8 {
  // lower 1-byte registers
  al,
  Cl,
  Dl,
  Bl,
  // higher 1 byte registers
  Ah,
  Ch,
  Dh,
  bh,
  // 2-byte registers
  ax,
  cx,
  dx,
  bx,
  sp,
  bp,
  si,
  di,
  // 4-byte registers
  eax,
  ecx,
  edx,
  ebx,
  esp,
  ebp,
  esi,
  edi,
  // 8-byte registers
  rax,
  rcx,
  rdx,
  rbx,
  rsp,
  rsi,
  rdi,
}

REX_PREFIX :: 0b0100
Rex_Byte :: bit_field u8 {
  prefix: u8 | 4,
  w: bool | 1,
  r: bool | 1,
  x: bool | 1,
  b: bool | 1,
}

X64_Operand :: union {

}

X64_Instruction :: struct {
  
}



// fix change r2 to R/M
create_reg_rm_byte :: proc(mod: Mod_Kind, reg, r2: Register_Kind ) -> u8 {
  //     MOD            REG                     R/M
  return (u8(mod) << 6) | ((u8(r2) % 8) << 3) | ((u8(reg) % 8))
}


encode_add :: proc(b: ^Builder, reg, r2: Register_Kind) {
  S_BIT :: 0b00000001
  D_BIT :: 0b00000010
  opcode: u8 
  switch reg {
    case .al..=.bh:
    case .ax..=.di:
      opcode |= S_BIT
    case .eax..=.edi: 
      opcode |= S_BIT
    case .rax..=.rdi:
      opcode |= S_BIT
      // TODO determine the REX prefix

      append(&b.buf, 0x48)
    case:
      panic("not implemented yet")
  }

  operands := create_reg_rm_byte(.Register, reg, r2)

  append(&b.buf, opcode, operands)
}

encode_return :: proc(b: ^Builder) {
  append(&b.buf, X64_RET)
}