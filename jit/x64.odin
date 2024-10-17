package leaf_jit

// import "core:fmt" // remove
X64_RET :: 0xC3

S_BIT :: 0b00000001
D_BIT :: 0b00000010

Operand_Kind :: enum u8 {
  Register = 1,
}


Mod_Kind :: enum u8 {
  None      = 0b00,
  S8        = 0b01,
  S32       = 0b10,
  Register  = 0b11,
}

Immediate :: int

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

x64_Byte_Opcode :: enum u8 {
  add = 0,
  mov = 0x88
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
  Register_Kind,
  Immediate,
}




// fix change r2 to R/M
create_reg_rm_byte :: proc(mod: Mod_Kind, reg, r2: Register_Kind ) -> u8 {
  //     MOD            REG                     R/M
  return (u8(mod) << 6) | ((u8(r2) % 8) << 3) | ((u8(reg) % 8))
}


encode_add :: proc(b: ^Builder, reg, rm: X64_Operand) {
  
}

encode_mov :: proc(b: ^Builder, op1, op2: X64_Operand) {
  opcode, reg, rm: u8 = 0x88, 0, 0
  
  _, op1_is_immediate := op1.(Immediate)
  assert(!op1_is_immediate, "First operand cannot be a Immediate")


  // should we encode the size bit

}

encode_return :: proc(b: ^Builder) {
  append(&b.buf, X64_RET)
}