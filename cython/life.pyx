# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
# cython: initializedcheck=False
# cython: cdivision = True
# cython: always_allow_keywords =False
# cython: unraisable_tracebacks = False
# cython: binding = False

from cython.cimports.cpython cimport array as arr  # type: ignore
from cython.cimports.libc.stdlib cimport rand  # type: ignore
from cython.cimports.cpython.mem cimport PyMem_Malloc, PyMem_Free  # type: ignore
from cpython cimport array

cdef class Life:
    cdef int[4][4] colors
    cdef signed char[2][9] rules
    cdef array.array lookupdata
    cdef int height, width, size, array_size, display_size

    def set_colors(self, colors):
        for _ in range(4):
            self.colors[_] = array.array("B", colors[_])

    def __init__(self, width, height, colors, rules):
       
        self.set_colors(colors)
        for _ in range(2):
            self.rules[_] = array.array("b", rules[_])
        self.height = height
        self.width = width
        self.size = height * width
        self.array_size = self.size * 8
        self.display_size = self.size * 4
        self.lookupdata = arr.array("i", [0] * self.array_size)

        cdef int y, x, skip, y3, y4, x3, index=0

        for y in range(0, height):
            for x in range(0, width):
                skip = 0
                for y3 in range(y - 1, y + 2):
                    y3 = y3 % height
                    y4 = y3 * width
                    for x3 in range(x - 1, x + 2):
                        skip += 1
                        if skip == 5:
                            continue
                        x3 = x3 % width
                        self.lookupdata[index] = y4 + x3
                        index += 1

    def randomize(self, game, factor):
        world: arr.array = game.life[game.world]

        for x in range(0, self.size):
            world[x] = rand() % factor == 1

    def generation(self, game):
        cdef int index = 0
        cdef int total = 0

        cdef array.array this_world_ = game.life[game.world]
        cdef char* this_world = this_world_.data.as_chars

        cdef array.array other_world_ = game.life[not game.world]
        cdef char* other_world = other_world_.data.as_chars

        cdef array.array l_ = self.lookupdata
        cdef int* l = l_.data.as_ints

        rules = self.rules

        for position in range(0, self.size):
            total = 0
            for neighbor in range(0, 8):
                total += this_world[l[index]] > 0
                index += 1

            other_world[position] = (
                rules[
                    this_world[position] > 0
                ][total]
            )

        game.world = not game.world

    def render(self, game):
        cdef array.array this_world_ = game.life[game.world]
        cdef char* world = this_world_.data.as_chars
        
        cdef array.array imagebuffer_ = game.buffer
        cdef unsigned char* imagebuffer = imagebuffer_.data.as_uchars

        cdef int world_pos = 0
        cdef int wv, world_value
        cdef int display_pos, color_byte

        for display_pos in range(0, self.display_size, 4):
            world_value = world[world_pos]
            wv = world_value + 1
            for color_byte in range(0, 4):
                imagebuffer[display_pos + color_byte] = self.colors[wv][color_byte]
            world_pos += 1
