package jam_language

import "base:runtime"
import "core:fmt"
import "core:strings"

Index :: distinct u32


Node_Data :: bit_field u32 {
  _res: u32 | 32,
}

Node :: struct {
  first_tag, last_tag: Index,
  first_child, last_child: Index,
  next, prev: Index,
  token: Token,
  data: Node_Data,
} 


Parser :: struct {
  src: []u8,
  tokens: []Token,
  curr: int,
  nodes: [dynamic]Node,
}

@private get_current_node :: proc(p: ^Parser) -> (node: ^Node, ok: bool){
  N := len(p.nodes)
  if N < 1 do return

  return &p.nodes[N - 1], true
}

@private get_current_index :: proc(p: ^Parser) -> Index {
  return Index(len(p.nodes)) - 1
} 

@private token_increment :: proc(p: ^Parser) -> (token: Token, ok: bool) {
  p.curr += 1
  if p.curr >= len(p.tokens) do return
  return p.tokens[p.curr], true
}



parser_init_tokens :: proc(p: ^Parser, tokens: []Token, allocator:=context.allocator) -> (parser: ^Parser, err: runtime.Allocator_Error){
  return
}

parser_init_from_tokenizer :: proc(
  p: ^Parser, 
  t: ^Tokenizer, 
  allocator:=context.allocator
) -> (parser: ^Parser, err: runtime.Allocator_Error) {
  p.src = t.src
  p.tokens = t.tokens[:]
  p.nodes = make([dynamic]Node, allocator) or_return
  parser = p
  return
}

parser_init :: proc{parser_init_from_tokenizer}

push_child :: proc(p: ^Parser, parent, child: Index) {
  par := &p.nodes[parent]

  if par.last_child == 0 {
    assert(par.first_child == 0)
    par.first_child = child
    par.last_child = child
  } else {
    // get the last node 
    prev := &p.nodes[par.last_child]
    // set it's next to the new last
    prev.next = child
    // get the new last node
    last := &p.nodes[child]
    // set the new last's prev to the old last
    last.prev = par.last_child
    // set the parent's last child to the new last
    par.last_child = child
  }
}

push_tag :: proc(p: ^Parser, parent, tag: Index) {
  par := &p.nodes[parent]

  if par.last_tag == 0 {
    assert(par.first_child == 0)
    par.first_tag = tag
    par.last_tag = tag
  } else {
    // get the last node 
    prev := &p.nodes[par.last_tag]
    // set it's next to the new last
    prev.next = tag
    // get the new last node
    last := &p.nodes[tag]
    // set the new last's prev to the old last
    last.prev = par.last_tag
    // set the parent's last child to the new last
    par.last_tag = tag
  }
}

parse_tag :: proc(p: ^Parser) -> Index {
  token := p.tokens[p.curr]
  
  append(&p.nodes, Node{token = token})
  node, ok := get_current_node(p)
  assert(ok)
  index := get_current_index(p)

  token, ok = token_increment(p)
  if !ok do return index

  if token.kind == .Left_Paren {
    _, ok = token_increment(p)
    assert(ok)

    parse_node(p)

    token = p.tokens[p.curr]
    assert(token.kind == .Right_Paren)
  } 
  
  return index
}

parse_node :: proc(p: ^Parser) -> Index {
  token := p.tokens[p.curr]
  
  append(&p.nodes, Node{token = token})
  node, ok := get_current_node(p)
  assert(ok)
  index := get_current_index(p)
  
  

  token, ok = token_increment(p)

  if !ok do return index

  for token := p.tokens[p.curr]; token.kind == .Tag && p.curr < len(p.tokens); {
    push_tag(p, index, parse_tag(p))
  }

  // a colon means that the node has children
  if token.kind == .Colon {
    token, ok = token_increment(p)
    assert(ok)

    #partial switch token.kind {
      case .Left_Brace:
        token, ok = token_increment(p)
        for token = p.tokens[p.curr]; token.kind == .Identifier && p.curr < len(p.tokens); {
          push_child(p, index, parse_node(p))
        }
        assert(token.kind == .Right_Brace) 
      case .Left_Paren:
        token, ok = token_increment(p)
        for token = p.tokens[p.curr]; token.kind == .Identifier && p.curr < len(p.tokens); {
          push_child(p, index, parse_node(p))
        }
        assert(token.kind == .Right_Paren)
      case .Identifier:
        push_child(p, index, parse_node(p))
      case:
        assert(false)
    }
  }





  return index
}

parse :: proc(p: ^Parser) {
  append(&p.nodes, Node{})

  for token := p.tokens[p.curr]; token.kind == .Identifier && p.curr < len(p.tokens); {
    push_child(p, 0, parse_node(p))
  }
}

write_tree :: proc(p: ^Parser) {
  write_node :: proc(p: ^Parser, node: Index) {

  }
}

main :: proc() {
  src := "main @fn @ret(int) {return: 0}"

  t, err := tokenizer_init(&Tokenizer{}, transmute([]u8)src)

  scan(t)

  tokens := t.tokens

  print_tokens(t)

  p, err2 := parser_init(&Parser{}, t)

  parse(p)

  fmt.println(p)

}
