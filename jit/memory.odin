package leaf_jit


import "base:runtime"
import vmem "core:mem/virtual"
import "core:sync"

// DEFAULT_ARENA_STATIC_RESERVE_SIZE :: vmem.DEFAULT_ARENA_STATIC_RESERVE_SIZE

// arena_array_allocator_proc :: proc(allocator_data: rawptr, mode: runtime.Allocator_Mode,
//   size, alignment: int,
//   old_memory: rawptr, old_size: int,
//   location := #caller_location) -> (data: []byte, err: runtime.Allocator_Error) {
// arena := (^vmem.Arena)(allocator_data)

// size, alignment := uint(size), uint(alignment)
// old_size := uint(old_size)

// switch mode {
// case .Alloc, .Alloc_Non_Zeroed:
// return arena_array_alloc(arena, size, alignment, location)
// case .Free:
// err = .Mode_Not_Implemented
// case .Free_All:
// arena_free_all(arena, location)
// case .Resize, .Resize_Non_Zeroed:
// old_data := ([^]byte)(old_memory)

// switch {
// case old_data == nil:
// return arena_alloc(arena, size, alignment, location)
// case size == old_size:
// // return old memory
// data = old_data[:size]
// return
// case size == 0:
// err = .Mode_Not_Implemented
// return
// case (uintptr(old_data) & uintptr(alignment-1) == 0) && size < old_size:
// // shrink data in-place
// data = old_data[:size]
// return
// }

// new_memory := arena_alloc(arena, size, alignment, location) or_return
// if new_memory == nil {
// return
// }
// copy(new_memory, old_data[:old_size])
// return new_memory, nil
// case .Query_Features:
// set := (^mem.Allocator_Mode_Set)(old_memory)
// if set != nil {
// set^ = {.Alloc, .Alloc_Non_Zeroed, .Free_All, .Resize, .Query_Features}
// }
// case .Query_Info:
// err = .Mode_Not_Implemented
// }

// return
// }

// // Allocates memory from the provided arena.
// @(require_results)
// arena_array_alloc :: proc(arena: ^vmem.Arena, size: uint, alignment: uint, loc := #caller_location) -> (data: []byte, err: runtime.Allocator_Error) {
// 	assert(alignment & (alignment-1) == 0, "non-power of two alignment", loc)

// 	size := size
// 	if size == 0 {
// 		return nil, nil
// 	}

// 	sync.mutex_guard(&arena.mutex)

// 	switch arena.kind {
// 	case .Growing:
//     panic("Virtual Dynamic Arrays do not support growing arena allocators")
// 	case .Static:
// 		if arena.curr_block == nil {
// 			if arena.minimum_block_size == 0 {
// 				arena.minimum_block_size = DEFAULT_ARENA_STATIC_RESERVE_SIZE
// 			}
// 			arena_init_static(arena, reserved=arena.minimum_block_size, commit_size=DEFAULT_ARENA_STATIC_COMMIT_SIZE) or_return
// 		}
// 		if arena.curr_block == nil {
// 			return nil, .Out_Of_Memory
// 		}
// 		data, err = alloc_from_memory_block(arena.curr_block, size, alignment, default_commit_size=arena.default_commit_size)
// 		arena.total_used = arena.curr_block.used

// 	case .Buffer:
// 		if arena.curr_block == nil {
// 			return nil, .Out_Of_Memory
// 		}
// 		data, err = alloc_from_memory_block(arena.curr_block, size, alignment, default_commit_size=0)
// 		arena.total_used = arena.curr_block.used
// 	}
// 	return
// }


// virtual_dyamic_array_allocator_proc :: proc(allocator_data: rawptr, mode: runtime.Allocator_Mode,
//   size, alignment: int,
//   old_memory: rawptr, old_size: int,
//   location := #caller_location) -> ([]byte, runtime.Allocator_Error) {


//     vmem.arena_allocator_proc()
// }