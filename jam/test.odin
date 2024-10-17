package jam_language



import "core:testing"
import "core:log"

@(test) test_vector3_tokens :: proc(t: ^testing.T) {
  context.logger = log.create_console_logger()

  vec3 := `
    @struct Vector3: {
      @float x,
      @float y,
      @float z,
    }
  `

  t, err := tokenizer_init(&Tokenizer{}, transmute([]byte)vec3)

  scan(t)

  tokens := t.tokens

  log.debug(tokens)
}