package leaf_jit

import vmem "core:mem/virtual"
import "core:mem"
import "core:fmt"
import "base:builtin"

Fn_I64_I64 :: #type proc(x: i64) -> i64

encode_add_eax :: proc(iv: i32) -> (instr: [5]u8) {
  iv := iv
  instr[0] = 0x05
  mem.copy(&instr[1], &iv, size_of(i32))

  return instr
}

main :: proc() {
  code_arena := &vmem.Arena{} // Do not use
  exe_err := vmem.arena_init_static(code_arena) 
  codebuf := make([dynamic]u8, 0, vmem.DEFAULT_ARENA_STATIC_COMMIT_SIZE)
  
  identity_fn_data := [?]u8 { 0x48, 0x89, 0xC8, 0x05, 0x5f, 0x01, 0x00, 0x00, X64_RET} 
  for byte in identity_fn_data do append(&codebuf, byte)
  some_fn := transmute(Fn_I64_I64)(raw_data(codebuf[:]))

  vmem.protect(raw_data(codebuf[:]), len(codebuf), {.Execute})

  fmt.println("Did this work", codebuf, some_fn(69))

  

}