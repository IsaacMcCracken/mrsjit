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

Node_Iterator :: struct {
  curr, next: Index
}

get_node :: proc(p: ^Parser, index: Index) -> ^Node {
  return &p.nodes[index]
}

iterator_head :: proc(p: ^Parser, index: Index) -> (iter: Node_Iterator) {
  iter.curr = index

  if index != 0 {
    iter.next = p.nodes[index].next
  }

  return
}

iterator_children_head :: proc(p: ^Parser, index: Index) -> (iter: Node_Iterator) {
  parent := &p.nodes[index]

  return iterator_head(p, parent.first_child)
}

iterator_tags_head :: proc(p: ^Parser, index: Index) -> (iter: Node_Iterator) {
  parent := &p.nodes[index]

  return iterator_head(p, parent.first_tag)
}


iterate_forward :: proc(p: ^Parser, iter: ^Node_Iterator) -> (node: Index, ok: bool) {
  res := iter.curr
  ok = res != 0

  iter.curr = iter.next

  iter.next = 0
  if iter.curr != 0 {
    iter.next = p.nodes[iter.curr].next
  }


  return res, ok
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

count_from_head :: proc(p: ^Parser, first_index: Index) -> (count: int) {
  iter := iterator_head(p, first_index)

  for node in iterate_forward(p, &iter) {
    count += 1
  }

  return
}

count_children :: proc(p: ^Parser, parent: Index) -> (count: int) {
  par := &p.nodes[parent]

  return count_from_head(p, par.first_child)
}


count_tags :: proc(p: ^Parser, parent: Index) -> (count: int) {
  par := &p.nodes[parent]

  return count_from_head(p, par.first_tag)
}

has_tag :: proc(p: ^Parser, parent: Index, tag_name: string) -> bool {
  iter := iterator_tags_head(p, parent)

  for index in iterate_forward(p, &iter) {

    tag := get_node(p, index)
    this_name := string(p.src[tag.token.start : tag.token.end])

    if this_name == tag_name do return true
  }

  return false
}

has_children :: proc(p: ^Parser, parent: Index) -> bool {
  node := get_node(p, parent)

  if node.last_child != 0 {
    assert(node.first_child != 0)
    return true
  }

  return false
}

parse_tag :: proc(p: ^Parser) -> Index {
  token := p.tokens[p.curr]
  assert(token.kind == .Tag)

  
  append(&p.nodes, Node{token = token})
  node, ok := get_current_node(p)
  assert(ok)
  index := get_current_index(p)

  token, ok = token_increment(p)
  if !ok do return index

  if token.kind == .Left_Paren {
    token, ok = token_increment(p)
    assert(ok)

    for token = p.tokens[p.curr]; token.kind == .Identifier && p.curr < len(p.tokens); token = p.tokens[p.curr]{
      push_child(p, index, parse_node(p))
    }

    token = p.tokens[p.curr]
    line, col := get_token_position(p.src, token)
    name := string(p.src[token.start:token.end])
    fmt.assertf(token.kind == .Right_Paren, "(%i:%i) %s: Expected %v got %v", line, col, name, Token_Kind.Right_Paren, token.kind)

    token, ok = token_increment(p)
  } 
  
  return index
}

parse_node :: proc(p: ^Parser) -> Index {
  token := p.tokens[p.curr]
  fmt.assertf(token.kind == .Identifier, "Expected %v got %v", Token_Kind.Identifier, token.kind)
  assert(token.kind == .Identifier)
  
  append(&p.nodes, Node{token = token})
  node, ok := get_current_node(p)
  assert(ok)
  index := get_current_index(p)
  
  

  token, ok = token_increment(p)

  if !ok do return index

  // TODO:(Isaac) make a token iterator
  for token = p.tokens[p.curr]; 
      token.kind == .Tag && p.curr < len(p.tokens);
      token = p.tokens[p.curr] {
    push_tag(p, index, parse_tag(p))
  }

  // a colon means that the node has children
  if token.kind == .Colon {
    token, ok = token_increment(p)
    assert(ok)

    #partial switch token.kind {
      case .Left_Brace:
        token, ok = token_increment(p)

        for token = p.tokens[p.curr];
          token.kind == .Identifier && p.curr < len(p.tokens);
          token = p.tokens[p.curr] {
          push_child(p, index, parse_node(p))
        }

        line, col := get_token_position(p.src, token)
        name := string(p.src[token.start:token.end])
        fmt.assertf(token.kind == .Right_Brace, "(%i:%i) %s: Expected %v got %v", line, col, name, Token_Kind.Right_Paren, token.kind)
            token, ok = token_increment(p)
      case .Left_Paren:
        token, ok = token_increment(p)

        for token = p.tokens[p.curr];
          token.kind == .Identifier && p.curr < len(p.tokens);
          token = p.tokens[p.curr] {
          push_child(p, index, parse_node(p))
        }

        assert(token.kind == .Right_Paren)
        token, ok = token_increment(p)
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

  token: Token
  for token = p.tokens[p.curr];
    token.kind == .Identifier && p.curr < len(p.tokens);
    token = p.tokens[p.curr] {
    push_child(p, 0, parse_node(p))
    
    // token_increment(p)
    if p.curr >= len(p.tokens) do break
  }

  fmt.println("LOOKIE:", token)

}

write_tree :: proc(b: ^strings.Builder, p: ^Parser) {
  write_node :: proc(b: ^strings.Builder, p: ^Parser, node: Index, indent: int) {
    cur := &p.nodes[node]
    str := p.src[cur.token.start:cur.token.end]
    for i in 0..<indent do strings.write_byte(b, ' ')
    strings.write_bytes(b, str)

    // write tags
    if cur.last_tag != 0 {
      assert(cur.first_tag != 0)
      
      iter := iterator_head(p, cur.first_tag)

      for tag in iterate_forward(p, &iter) {
        
        tagn := &p.nodes[tag]
        
        str := p.src[tagn.token.start:tagn.token.end]
        strings.write_string(b, " @")
        strings.write_bytes(b, str)
        strings.write_byte(b, ' ')

      }

    }
    
    // write children
    if cur.last_child != 0 {
      assert(cur.first_child != 0)
      strings.write_string(b, ": {\n")
      
      iter := iterator_head(p, cur.first_child)

      for child in iterate_forward(p, &iter) {
        // fmt.println("BOZOBOZO:", child)

        write_node(b, p, child, indent + 1)
        strings.write_byte(b, '\n')
      }

      for i in 0..<indent do strings.write_rune(b, ' ')
      strings.write_string(b, "}\n")
    }
  }

  write_node(b, p, 0, 0)
}


print_nodes :: proc(p: ^Parser) {
  for node, i in p.nodes {
    name := string(p.src[node.token.start:node.token.end])
    fmt.printf("%02i %010s TF: %02i TL: %02i CF %02i CL: %02i\n", i, name, node.first_tag, node.last_tag, node.first_child, node.last_child)
  }
}

main :: proc() {
  // src := "main @fn @ret(int) : {return: 0}"
  // t, err := tokenizer_init(&Tokenizer{}, transmute([]u8)src)

  src := #load("test.jam")
  t, err := tokenizer_init(&Tokenizer{}, transmute([]u8)src)


  scan(t)

  tokens := t.tokens

  print_tokens(t)

  p, err2 := parser_init(&Parser{}, t)

  parse(p)

  print_nodes(p)

  b, err3 := strings.builder_init(&strings.Builder{})
  write_tree(b, p)

  tree := strings.to_string(b^)

  fmt.println(p.nodes[1])

  fmt.print(tree)

}
