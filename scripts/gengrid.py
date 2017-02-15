#!/usr/bin/env python3
import cairo as c
import pprint
import random
import time

#definitions of the colors
RED     = (1.0, 0.0, 0.0)
GREEN   = (0.0, 1.0, 0.0)
BLUE    = (0.0, 0.0, 1.0)
RED     = (1.0, 0.0, 0.0)
YELLOW  = (1.0, 1.0, 0.0)
MAGENTA = (1.0, 0.0, 1.0)
CYAN    = (0.0, 1.0, 1.0)

#and "Colors"
WHITE   = (1.0, 1.0, 1.0)
BLACK   = (0.0, 0.0, 0.0)

class Grid(object):
    ''' Defines a grid. '''

    WHITE   = 0
    BLACK   = 1

    RED     = 2
    GREEN   = 3
    BLUE    = 4
    YELLOW  = 5
    MAGENTA = 6
    CYAN    = 7
    
    def __init__(self, nrows, ncols):

        #dimensions of the grid
        self.nr     = nrows
        self.nc     = ncols

        #indices to white and black
        self.white  = []
        self.black  = []
        self.matrix = []
        self._initMatrix()
        random.shuffle(self.white)
        random.shuffle(self.black)

    def _initMatrix(self):
        self.matrix = [[self._defaultValue(i,j) for j in range(self.nr)]
                       for i in range(self.nc)
                       ]

        ''' Inits black and white indices.'''
        index = 0;
        for row in range(self.nc):
            for col in range(self.nr):
                if self._isWhite(row, col):
                    self.white.append((row, col))
                else:
                    self.black.append((row, col))

    def print(self):
        pprint.pprint(self.matrix, depth=2)

    def _isWhite(self, row, column):
        ''' Determines whether a field is white by default '''
        # On even rows even columns are white and vice versa
        if row % 2 == 0:
            return column % 2 == 0
        else:
            return column % 2 != 0

    def _isBlack(self, row, column):
        ''' Determines whether a field is black by default '''
        return not self.isWhite(row, column)

    def _defaultValue(self, x, y):
        if self._isWhite(x, y):
            return self.WHITE
        else:
            return self.BLACK
    
    def addColorRandomOnWhite(self, color, once=False):
        '''
        If once is true the same square won't be assigned another color anymore.
        '''
        if once == True:
            index = self.white.pop()
            self.matrix[index[0]][index[1]] = color
        else:
            random.shuffle(self.white)
            index = self.white[0]
            self.matrix[index[0]][index[1]] = color

    def addColorRandomOnBlack(self, color, once=False):
        '''
        If once is true the same square won't be assigned another color anymore.
        '''
        if once:
            index = self.black.pop()
            self.matrix[index[0]][index[1]] = color
        else:
            random.shuffle(self.black)
            index = self.black[0]
            self.matrix[index[0]][index[1]] = color

    def color(self, row, column):
        return self.matrix[row][column]

    def rows(self): return self.nr

    def columns(self): return self.nc

colortable = {
    Grid.WHITE   : WHITE,
    Grid.BLACK   : BLACK,
    Grid.RED     : RED,
    Grid.GREEN   : GREEN,
    Grid.BLUE    : BLUE,
    Grid.YELLOW  : YELLOW,
    Grid.MAGENTA : MAGENTA,
    Grid.CYAN    : CYAN
}

width = 800.0
height= 800.0

def create_grid_svg(name, grid, width, height):
    ''' Paints the grid on to a svg image '''
    surf = c.SVGSurface(name, width, height)
    cr = c.Context(surf)
    for row in range(g.rows()):
        for col in range(g.columns()):
            color = colortable[g.color(row, col)]
            cr.set_source_rgb(color[0], color[1], color[2])
            x = col * width / g.columns()
            y = row * height/ g.rows()
            w = width / g.columns()
            h = height/ g.rows()
            cr.rectangle(x, y, w, h)
            cr.fill()

if __name__ == "__main__":
    seed = int(time.time() * 1e6)
    print ("seed = ", seed)
    random.seed(seed)
    ncolors = 2 
    assign = [int(i/ncolors)
              for i in range(Grid.RED * ncolors, (Grid.CYAN+1) * ncolors)
              ]
    numpics = 64

    for i in range(numpics):
        g = Grid(8, 8)
        # shuffle assign, since the last color in the list will never be
        # overwritten. And how later you are in the list the lower the chance
        # will be
        random.shuffle(assign)
        for color in assign:
            g.addColorRandomOnWhite(color)

        name = "cboard{:02d}.svg".format(i)
        create_grid_svg(name,g, width, height)

