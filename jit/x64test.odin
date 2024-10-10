package leaf_jit

import vmem "core:mem/virtual"
import mem "core:mem"
import "core:slice"

import "core:testing"

@(test)
add_eax_ecx_ret :: proc(t: ^testing.T) {
  b, err := builder_init(&Builder{}) 
  testing.expect(t, err == .None)
  defer delete(b.buf)

  expected := []u8{ 0x01, 0xC8, 0xC3 } 

  encode_add(b, .eax, .ecx)
  encode_return(b)

  ok := mem.compare(b.buf[:], expected) == 0

  testing.expect(t, ok, "add eax, ecx | ret")
}

@(test)
add_rax_rcx_ret :: proc(t: ^testing.T) {
  b, err := builder_init(&Builder{}) 
  testing.expect(t, err == .None, "Are we failing here")
  defer delete(b.buf)

  expected := []u8{ 0x48, 0x01, 0xC8, 0xC3 } 

  encode_add(b, .rax, .rcx)
  encode_return(b)

  ok := mem.compare(b.buf[:], expected) == 0

  testing.expectf(t, ok, "add rax, rcx | ret (Expected %X. Got %X)", expected, b.buf[:])
}
