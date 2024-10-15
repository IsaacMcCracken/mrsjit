package jam_language

import "base:runtime"
import "core:fmt"
import "core:os"


Token_Kind :: enum u32 {
  Invalid,
  Tag,
  Identifier,
  Left_Paren,
  Right_Paren,
  Left_Brace,
  Right_Brace,
  Colon,
  Comma,
  Semicolon,

}

Token :: struct {
  kind: Token_Kind,
  start, end: u32,
}

Tokenizer :: struct {
  src: []byte,
  curr, prev: u32,
  tokens: [dynamic]Token,
}

tokenizer_init :: proc{tokenizer_init_src}

tokenizer_init_src :: proc(
  t: ^Tokenizer,
  src: []byte, 
  allocator:=context.allocator
) -> (tokenizer: ^Tokenizer, err: runtime.Allocator_Error) {
  assert(t != nil, "Cannot initalize nil reference to tokenizer.")
  t.tokens = make([dynamic]Token, allocator) or_return
  t.src = src
  t.curr = 0
  tokenizer = t
  return 
} 


emit_token :: proc(t: ^Tokenizer, kind: Token_Kind) {
  token := Token{
    kind = kind,
    start = t.prev,
    end = t.curr
  }

  append(&t.tokens, token)

}

is_whitespace_rune :: proc(r: rune) -> bool {
  switch r {
    case ' ', '\n', '\t', '\r':
      return true
  }

  return false
}

skip_whitespace :: proc(t: ^Tokenizer) {
  for t.curr < u32(len(t.src)) && is_whitespace_rune(rune(t.src[t.curr])) do t.curr += 1
}

is_identifier_char :: proc(r: rune) -> bool {
  switch r {
    case  'a'..='z', 'A'..='Z', '0'..='9', '_', '!', '#', '$', '%', '^', '&', '*', '/', '+', '-', '?':
      return true
  }

  return false
}

scan_tag :: proc(t: ^Tokenizer) {
  t.curr += 1
  t.prev = t.curr
  scan_identifier(t)
}

scan_identifier :: proc(t: ^Tokenizer) {
  for t.curr < u32(len(t.src)) && is_identifier_char(rune(t.src[t.curr])) do t.curr += 1
}

scan_string :: proc(t: ^Tokenizer) {
  t.curr += 1
  t.prev = t.curr
  for t.curr < u32(len(t.src)) && t.src[t.curr] != '"' do t.curr += 1
  t.curr += 1
}



scan :: proc(t: ^Tokenizer) {
  n := u32(len(t.src))
  for t.curr < n {
    t.prev = t.curr
    switch t.src[t.curr] {
      case ' ', '\n', '\t', '\r':
        skip_whitespace(t)
      case '(':
        t.curr += 1
        emit_token(t, .Left_Paren)
      case ')':
        t.curr += 1
        emit_token(t, .Right_Paren)
      case '{':
        t.curr += 1
        emit_token(t, .Left_Brace)
      case '}':
        t.curr += 1
        emit_token(t, .Right_Brace)
      case '@':
        scan_tag(t)
        emit_token(t, .Tag)
      case ':':
        t.curr += 1
        emit_token(t, .Colon)
      case ',':
        t.curr += 1
        emit_token(t, .Comma)
      case ';':
        t.curr += 1
        emit_token(t, .Semicolon)

      case  'a'..='z', 'A'..='Z', '0'..='9', '_', '!', '#', '$', 
            '%', '^', '&', '*', '/', '+', '-', '?':
        scan_identifier(t)
        emit_token(t, .Identifier)
      case '"':
        scan_string(t)
        emit_token(t, .Identifier)
      case:
        t.curr += 1
        emit_token(t, .Invalid)
    }

  }
}

test_tokenizer :: proc() {
  src := #load("test.jam")

  t, err := tokenizer_init(&Tokenizer{}, src)

  scan(t)

  tokens := t.tokens

  print_tokens(t)
}


print_tokens :: proc(t: ^Tokenizer) {
  fmt.println("Tokens {")
  for token in t.tokens {
    fmt.println(' ', token.kind, "->", string(t.src[token.start:token.end]))
  }
  fmt.println('}')

}


