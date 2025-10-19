return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 40,
  height = 25,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 19,
  nextobjectid = 311,
  properties = {},
  tilesets = {
    {
      name = "cdntileset",
      firstgid = 1,
      class = "",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 7,
      image = "cdn.png",
      imagewidth = 224,
      imageheight = 128,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      wangsets = {},
      tilecount = 28,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 25,
      id = 12,
      name = "ground",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 2, 3, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 22, 22, 22, 22, 22, 22, 8, 9, 10, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 15, 16, 17, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 24, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 22, 6, 24, 22, 6, 2, 22, 6, 22, 16, 6, 22, 24, 6, 22, 22, 6, 22, 22, 6, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 1, 22, 6, 22, 22, 6, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 23, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 24, 6, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 23, 5, 24, 5, 5, 1, 22, 6, 22, 24, 22, 6, 22, 22, 6, 3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 8, 22, 6, 22, 22, 3, 5, 5, 5, 6, 5, 5, 23, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 23, 5, 24, 22, 22, 10, 5, 5, 5, 5, 5, 5, 5, 1, 24, 6, 5, 5, 5, 5, 15, 6, 3, 5, 23, 5, 5, 6, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 6, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 8, 22, 6, 3, 5, 23, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 1, 22, 6, 22, 22, 6, 22, 3, 5, 5, 5, 6, 5, 5, 15, 6, 10, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 24, 5, 5, 5, 1, 17, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 23, 24, 5, 5, 5, 6, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 23, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 15, 6, 22, 22, 6, 22, 22, 6, 22, 24, 6, 16, 22, 6, 22, 2, 6, 22, 16, 6, 22, 22, 6, 22, 22, 6, 22, 17, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 24, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 1, 2, 3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 23, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 8, 9, 9, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 15, 16, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 25,
      id = 16,
      name = "top",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 25, 0, 7, 0, 0, 7, 0, 0, 7, 0, 11, 7, 0, 0, 7, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 13, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 13, 0, 4, 0, 13, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 13, 0, 0, 0, 0, 0, 13, 0, 0, 0, 0, 0, 13, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 7, 0, 0, 0, 0, 0, 13, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 12, 0, 0, 0, 13, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 7, 0, 0, 7, 0, 11, 7, 0, 0, 7, 0, 0, 7, 0, 0, 7, 0, 0, 7, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 14,
      name = "Colliders",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 257,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 512,
          width = 704,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 258,
          name = "",
          type = "",
          shape = "rectangle",
          x = 352,
          y = 576,
          width = 352,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 259,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 576,
          width = 256,
          height = 224,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 262,
          name = "",
          type = "",
          shape = "rectangle",
          x = 256,
          y = 672,
          width = 1024,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 263,
          name = "",
          type = "",
          shape = "rectangle",
          x = 352,
          y = 640,
          width = 928,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 264,
          name = "",
          type = "",
          shape = "rectangle",
          x = 736,
          y = 512,
          width = 320,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 265,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1056,
          y = 544,
          width = 224,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 267,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1088,
          y = 512,
          width = 192,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 268,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1120,
          y = 0,
          width = 160,
          height = 512,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 269,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1056,
          y = 0,
          width = 64,
          height = 224,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 270,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1024,
          y = 0,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 271,
          name = "",
          type = "",
          shape = "rectangle",
          x = 736,
          y = 96,
          width = 288,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 272,
          name = "",
          type = "",
          shape = "rectangle",
          x = 736,
          y = 64,
          width = 192,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 274,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 928,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 275,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 32,
          width = 704,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 276,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 160,
          width = 384,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 277,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 192,
          width = 224,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 278,
          name = "",
          type = "",
          shape = "rectangle",
          x = 256,
          y = 224,
          width = 32,
          height = 256,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 279,
          name = "",
          type = "",
          shape = "rectangle",
          x = 288,
          y = 352,
          width = 96,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 280,
          name = "",
          type = "",
          shape = "rectangle",
          x = 288,
          y = 416,
          width = 64,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 281,
          name = "",
          type = "",
          shape = "rectangle",
          x = 288,
          y = 288,
          width = 96,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 282,
          name = "",
          type = "",
          shape = "rectangle",
          x = 320,
          y = 224,
          width = 64,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 283,
          name = "",
          type = "",
          shape = "rectangle",
          x = 384,
          y = 224,
          width = 192,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 284,
          name = "",
          type = "",
          shape = "rectangle",
          x = 416,
          y = 192,
          width = 160,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 285,
          name = "",
          type = "",
          shape = "rectangle",
          x = 416,
          y = 288,
          width = 288,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 286,
          name = "",
          type = "",
          shape = "rectangle",
          x = 416,
          y = 320,
          width = 224,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 287,
          name = "",
          type = "",
          shape = "rectangle",
          x = 416,
          y = 384,
          width = 160,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 288,
          name = "",
          type = "",
          shape = "rectangle",
          x = 384,
          y = 448,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 289,
          name = "",
          type = "",
          shape = "rectangle",
          x = 608,
          y = 416,
          width = 192,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 290,
          name = "",
          type = "",
          shape = "rectangle",
          x = 672,
          y = 352,
          width = 256,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 291,
          name = "",
          type = "",
          shape = "rectangle",
          x = 736,
          y = 320,
          width = 128,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 292,
          name = "",
          type = "",
          shape = "rectangle",
          x = 832,
          y = 384,
          width = 96,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 294,
          name = "",
          type = "",
          shape = "rectangle",
          x = 960,
          y = 384,
          width = 64,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 295,
          name = "",
          type = "",
          shape = "rectangle",
          x = 992,
          y = 416,
          width = 96,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 296,
          name = "",
          type = "",
          shape = "rectangle",
          x = 960,
          y = 448,
          width = 128,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 297,
          name = "",
          type = "",
          shape = "rectangle",
          x = 608,
          y = 192,
          width = 416,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 303,
          name = "",
          type = "",
          shape = "rectangle",
          x = 736,
          y = 256,
          width = 320,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 304,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1024,
          y = 288,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 306,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1056,
          y = 256,
          width = 32,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 307,
          name = "",
          type = "",
          shape = "rectangle",
          x = 896,
          y = 288,
          width = 96,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 308,
          name = "",
          type = "",
          shape = "rectangle",
          x = 960,
          y = 320,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        },
        {
          id = 310,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = -32,
          width = 1280,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["anchored"] = true
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 15,
      name = "Plates",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 142,
          name = "two1",
          type = "cdn_plate_num",
          shape = "rectangle",
          x = 512,
          y = 480,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["val"] = 2
          }
        },
        {
          id = 143,
          name = "three1",
          type = "cdn_plate_num",
          shape = "rectangle",
          x = 1056,
          y = 512,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["val"] = 3
          }
        },
        {
          id = 144,
          name = "add1",
          type = "cdn_plate_op",
          shape = "rectangle",
          x = 224,
          y = 416,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["op"] = "add"
          }
        },
        {
          id = 145,
          name = "mul1",
          type = "cdn_plate_op",
          shape = "rectangle",
          x = 512,
          y = 256,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["op"] = "mul"
          }
        },
        {
          id = 146,
          name = "add2",
          type = "cdn_plate_op",
          shape = "rectangle",
          x = 480,
          y = 160,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["op"] = "add"
          }
        },
        {
          id = 147,
          name = "five1",
          type = "cdn_plate_num",
          shape = "rectangle",
          x = 672,
          y = 320,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["val"] = 5
          }
        },
        {
          id = 148,
          name = "two2",
          type = "cdn_plate_num",
          shape = "rectangle",
          x = 800,
          y = 160,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["val"] = 2
          }
        },
        {
          id = 149,
          name = "three2",
          type = "cdn_plate_num",
          shape = "rectangle",
          x = 288,
          y = 320,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["val"] = 3
          }
        },
        {
          id = 150,
          name = "sub1",
          type = "cdn_plate_op",
          shape = "rectangle",
          x = 992,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["op"] = "sub"
          }
        },
        {
          id = 151,
          name = "seven1",
          type = "cdn_plate_num",
          shape = "rectangle",
          x = 1056,
          y = 224,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["val"] = 7
          }
        },
        {
          id = 152,
          name = "five2",
          type = "cdn_plate_num",
          shape = "rectangle",
          x = 960,
          y = 416,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["val"] = 5
          }
        },
        {
          id = 154,
          name = "mul2",
          type = "cdn_plate_op",
          shape = "rectangle",
          x = 288,
          y = 256,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["op"] = "mul"
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 17,
      name = "Paths",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 235,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 224,
          y = 480,
          width = 896,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 236,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 576,
          y = 384,
          width = 32,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 237,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 608,
          y = 384,
          width = 192,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 238,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 800,
          y = 384,
          width = 32,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 239,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 640,
          y = 320,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 240,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 704,
          y = 256,
          width = 32,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        },
        {
          id = 241,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 384,
          y = 256,
          width = 320,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        },
        {
          id = 242,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 736,
          y = 288,
          width = 160,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        },
        {
          id = 243,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 864,
          y = 320,
          width = 96,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        },
        {
          id = 244,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 928,
          y = 352,
          width = 32,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        },
        {
          id = 245,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 960,
          y = 352,
          width = 96,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 5
          }
        },
        {
          id = 246,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 1024,
          y = 384,
          width = 64,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 5
          }
        },
        {
          id = 247,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 1088,
          y = 224,
          width = 32,
          height = 256,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        },
        {
          id = 248,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 1024,
          y = 160,
          width = 32,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 250,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 384,
          y = 160,
          width = 640,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 251,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 704,
          y = 32,
          width = 32,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 5
          }
        },
        {
          id = 252,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 224,
          y = 192,
          width = 192,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        },
        {
          id = 253,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 224,
          y = 224,
          width = 32,
          height = 256,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 11
          }
        },
        {
          id = 254,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 384,
          y = 288,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 7
          }
        },
        {
          id = 255,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 352,
          y = 416,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 2
          }
        },
        {
          id = 256,
          name = "path",
          type = "cdn_path",
          shape = "rectangle",
          x = 576,
          y = 192,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["k"] = 3
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 18,
      name = "Objs",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 225,
          name = "door",
          type = "door",
          shape = "rectangle",
          x = 256,
          y = 576,
          width = 32,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["spawnx"] = 2.18,
            ["spawny"] = 2.9,
            ["to"] = "internetscn"
          }
        },
        {
          id = 227,
          name = "playerspawn",
          type = "udim2",
          shape = "point",
          x = 336,
          y = 624,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 228,
          name = "reset",
          type = "cdn_reset",
          shape = "rectangle",
          x = 704,
          y = 512,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 229,
          name = "shard",
          type = "shard",
          shape = "point",
          x = 976,
          y = 48,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "cdn_shard"
          }
        },
        {
          id = 230,
          name = "gateout",
          type = "cdn_gate_out",
          shape = "rectangle",
          x = 384,
          y = 608,
          width = 64,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 231,
          name = "gatein",
          type = "cdn_gate_in",
          shape = "rectangle",
          x = 640,
          y = 608,
          width = 64,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 233,
          name = "start",
          type = "cdn_start",
          shape = "rectangle",
          x = 480,
          y = 608,
          width = 128,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
