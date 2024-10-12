package leaf_jit

import vmem "core:mem/virtual"
import "core:mem"
import "core:fmt"
import "base:builtin"
import "core:strings"

Fn_I64_I64 :: #type proc(x: i64) -> i64

encode_add_eax :: proc(iv: i32) -> (instr: [5]u8) {
  iv := iv
  instr[0] = 0x05
  mem.copy(&instr[1], &iv, size_of(i32))

  return instr
}

/**
This is a code builder that you use to write raw x64 to

Procedures that use this data structure produce instructions
will have the prefix
*/
Builder :: struct {
  buf: [dynamic]byte,
}


builder_init :: proc{
  builder_init_none,
  builder_init_len,
  builder_init_len_cap,
}

builder_init_none :: proc(b: ^Builder, allocator:=context.allocator, loc := #caller_location) -> (res: ^Builder, err: mem.Allocator_Error) {
  b.buf = make([dynamic]byte, allocator, loc) or_return
  return b, nil
}

builder_init_len :: proc(b: ^Builder, len: uint, allocator:=context.allocator, loc := #caller_location) -> (res: ^Builder, err: mem.Allocator_Error) {
  b.buf = make([dynamic]byte, len, allocator, loc) or_return
  return b, nil
}

builder_init_len_cap :: proc(b: ^Builder, len, cap: uint, allocator:=context.allocator, loc := #caller_location) -> (res: ^Builder, err: mem.Allocator_Error) {
  b.buf = make([dynamic]byte, len, cap, allocator, loc) or_return
  return b, nil
}



main :: proc() {
  code_arena := &vmem.Arena{} // Do not use
  exe_err := vmem.arena_init_static(code_arena) 
  b, err := builder_init(&Builder{}, 0, vmem.DEFAULT_ARENA_STATIC_COMMIT_SIZE) 

  encode_mov(b, .rax, .rcx)
  encode_add(b, .rax, .rcx)
  encode_return(b)



  
  fn_main := transmute(Fn_I64_I64)(raw_data(b.buf))
  fmt.printfln("Code: %X", b.buf)
  vmem.protect(raw_data(b.buf[:]), len(b.buf), {.Execute})


  success := fn_main(32)
  fmt.println("Our program returned:", success)
}


