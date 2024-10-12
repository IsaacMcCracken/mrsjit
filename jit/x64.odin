package leaf_jit

// import "core:fmt" // remove
X64_RET :: 0xC3

S_BIT :: 0b00000001
D_BIT :: 0b00000010

Immediate :: i32

Operand_Kind :: enum u8 {
  Register = 1,
}

Operand :: union {
  Register_Kind,
  Immediate,
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
create_reg_rm_byte :: proc(mod: Mod_Kind, reg, rm: u8 ) -> u8 {
  //     MOD            REG                     R/M
  return (u8(mod) << 6) | (reg  << 3) | rm
}


encode_mov :: proc(b: ^Builder, reg, rm: Register_Kind) {
  opcode: u8 = 0x88
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

  operands := create_reg_rm_byte(.Register, u8(reg) % 8, u8(rm) % 8)
  append(&b.buf, opcode, operands)

}

encode_increment :: proc(b: ^Builder, reg: Register_Kind) {

}

encode_add :: proc(b: ^Builder, op1, op2: Operand) {
  no_reg_rm := false
  iv_size := 0
  opcode, reg, rm: u8 // all are zero
  mod: Mod_Kind
  

  if iv, ok := op2.(Immediate); ok {
    // TODO: operand might not be register
    register := op1.(Register_Kind)

    mod = .S32
    if u8(reg) % 8 == 0 {
      no_reg_rm = true
      opcode = 0x05
    } else {
      rm = u8(register) % 8
      

    }
  } else {
    mod = .Register
    rm = u8(op1.(Register_Kind)) % 8
    reg = u8(op2.(Register_Kind)) % 8
  }
  register := op1.(Register_Kind)
  switch register {
    case .al..=.bh:
      iv_size = 1
    case .ax..=.di:
      opcode |= S_BIT
      iv_size = 2
    case .eax..=.edi: 
      opcode |= S_BIT
      iv_size = 4
    case .rax..=.rdi:
      opcode |= S_BIT
      iv_size = 4
      // TODO determine the REX prefix

      append(&b.buf, 0x48)
    case:
      panic("not implemented yet")
  }

  operands := create_reg_rm_byte(mod, reg, rm)

  append(&b.buf, opcode, operands)
}

encode_return :: proc(b: ^Builder) {
  append(&b.buf, X64_RET)
}