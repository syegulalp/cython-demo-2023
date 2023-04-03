import array as arr
from random import random

def rand():
    return int(random() * 100)


class Life:
    def set_colors(self, colors: list):
        self.colors = colors

    def __init__(self, width, height, colors, rules):
        index = 0

        self.set_colors(colors)

        self.rules = rules

        self.height = height
        self.width = width
        self.size = height * width
        self.array_size = self.size * 8
        self.display_size = self.size * 4
        self.lookupdata = arr.array("i", [0] * self.array_size)

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
        index=0
        this_world: arr.array = game.life[game.world]
        other_world: arr.array = game.life[not game.world]

        l = self.lookupdata

        rules = self.rules

        for position in range(0, self.size):
            total = 0
            for neighbor in range(0, 8):
                total += this_world[l[index]] > 0
                index += 1

            other_world[position] = rules[this_world[position] > 0][total]

        game.world = not game.world

    def render(self, game):
        world: arr.array = game.life[game.world]
        imagebuffer: arr.array = game.buffer

        display_size = self.display_size
        world_pos = 0
        for display_pos in range(0, display_size, 4):
            world_value = world[world_pos]
            wv = world_value + 1
            for color_byte in range(0, 4):
                imagebuffer[display_pos + color_byte] = self.colors[wv][color_byte]
            world_pos += 1
