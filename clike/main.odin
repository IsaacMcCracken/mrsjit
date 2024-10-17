package clike


import "../jam"

import "core:os"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:strings"
// import "core:path"


main :: proc() {
  args := os.args

  arena := &vmem.Arena{}
  arena_err := vmem.arena_init_static(arena)

  if arena_err != .None {
    fmt.println("Could not allocate memory for arena:", arena_err)
    os.exit(-1)
  }

  defer vmem.arena_destroy(arena)

  file_list, file_list_err := make([dynamic]string)
  if file_list_err != .None do panic("Failed to create a dynamic array for files")
  defer delete(file_list)

  for arg, i in args {
    split, err := strings.split(arg, ".")
    if err != .None do panic("strings.split failed oh no")
    defer delete(split)

    ext := split[len(split) - 1]

    if ext == "jam" do append(&file_list, arg)
  }

  src, src_ok := os.read_entire_file(file_list[0])
  if !src_ok {
    fmt.println("Could not open file:", file_list[0])
    os.exit(1)
  }

  tokenizer, tokenizer_init_err := jam.tokenizer_init(&jam.Tokenizer{}, src)
  if tokenizer_init_err != .None do panic("Could not initalize tokenizer")
  defer delete(tokenizer.tokens)

  jam.scan(tokenizer)

  parser, parser_init_err := jam.parser_init(&jam.Parser{}, tokenizer)
  if parser_init_err != .None do panic("Could not initalize parser")
  defer delete(parser.nodes)

  jam.parse(parser)

  b, ignor := strings.builder_init(&strings.Builder{})
  jam.write_tree(b, parser)

  fmt.print(strings.to_string(b^))

  context.allocator = vmem.arena_allocator(arena)
  }