package clike

import "../jam"
import "core:os"
import "core:mem"
import "core:container/intrusive/list"
import "base:runtime"

Parse_Error :: struct {
  using link: list.Node,
  message: string,
}

Parse_Result :: struct {
  src: []u8,
  errs: list.List,
  decls: []Any_Node,
}

Function_Definition :: struct {
  proto: ^Function_Proto,
  body: ^Body
}

Function_Proto :: struct {
  name: string,
  parameter_names: []string,
  parameter_types: []Any_Node,
  return_type: Any_Node,
}

Body :: struct {
  statements: []Any_Node
}

Type_Struct :: struct {
  name: string,
  field_names: []string,
  field_types: []Any_Node,
}

Comment :: struct {
  comment: string
}

Type_Primitive :: enum u8 {
  Invalid,
  Int,
}

Any_Type :: union {
  ^Type_Struct
}

Any_Node :: union {
  ^Function_Proto,
  ^Body,
  ^Comment
}


parse_jam_to_clike :: proc(filename: string, p: ^jam.Parser, allocator:=context.allocator) -> (file: Parse_Result) {
  context.allocator = allocator


  decl_count := jam.count_children(p, 0)
  err: mem.Allocator_Error
  file.decls, err = make([]Any_Node, decl_count)

  iter := jam.iterator_children_head(p, 0)
  for &decl in file.decls {
    index, ok := jam.iterate_forward(p, &iter)
    assert(ok, "The amount of nodes in root should be the same as in file.decls")
    
    decl = parse_global_decl(p, index)
  }

  return
}


Global_Tags :: bit_set[Global_Tag]
Global_Tag :: enum u32 {
  Struct,
  Fn,
  Ret,
  Cmt,
  Var,
}

get_global_tags :: proc(p: ^jam.Parser, parent: jam.Index) -> (tags: Global_Tags) {
  iter := jam.iterator_tags_head(p, parent) 
  
  for index in jam.iterate_forward(p, &iter) {
    tag := jam.get_node(p, index)

    name := string(p.src[tag.token.start:tag.token.end])

    switch name {
      case "fn":
        tags |= {.Fn}
      case "cmt":
        tags |= {.Cmt} 
      case "ret":
        tags |= {.Ret}
      case "struct":
        tags |= {.Struct}
    }
  }


  return
}

parse_global_decl :: proc(p: ^jam.Parser, index: jam.Index) -> Any_Node {

  /**
    Lets think about what a decl can be.

    A decl can be a function prototype.
    A function
    A struct definition.
    A global variable.
  */

  iter := jam.iterator_tags_head(p, index) 

  for tag_index in jam.iterate_forward(p, &iter) {
    tag := jam.get_node(p, tag_index)

    name := string(p.src[tag.token.start:tag.token.end])

    switch name {
      case "fn":
      case "cmt":
      case "ret":
      case "struct":
    }
  }

}

parse_field_list :: proc(p: ^jam.Parser, first_index: jam.Index) -> (names: []string, types: []Any_Type) {
  
  decl_count := jam.count_from_head(p, first_index)

  err: mem.Allocator_Error
  names, err = make([]string, decl_count)
  types, err = make([]Any_Type, decl_count)
  
  iter := jam.iterator_head(p, first_index)

  for i in 0..<decl_count {
    index, ok := jam.iterate_forward(p, &iter)
    assert(ok)
    field_node := jam.get_node(p, index)

    name := string(p.src[field_node.token.start:field_node.token.end])



  }
}


parse_function_proto :: proc()
