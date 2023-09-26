import sys

arg_size = {
    "b": 8,
    "w": 16,
    "d": 32,
    "q": 64,
    "dq": 128
}

# Input string
input_string = sys.argv[2]

if len(input_string) < 128:
    input_string = "0" * (128 - len(input_string)) + input_string

size = arg_size[sys.argv[1]]

# Using a list comprehension
chunks = [input_string[i:i+size] for i in range(0, len(input_string), size)]

chunks_per_line = 4
for i in range(0, len(chunks), chunks_per_line):
    chunk_line = chunks[i:i+chunks_per_line]
    print(" ".join(str(int(chunk, 2)) for chunk in chunk_line))