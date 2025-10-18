return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 40,
  height = 40,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 4,
  nextobjectid = 65,
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
      columns = 5,
      image = "cdn.png",
      imagewidth = 160,
      imageheight = 160,
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
      tilecount = 25,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 40,
      height = 40,
      id = 1,
      name = "Path",
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
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 1, 2, 3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 6, 7, 7, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 11, 12, 13, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 1, 16, 16, 16, 16, 16, 16, 16, 16, 7, 16, 16, 16, 2, 16, 16, 3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 17, 5, 5, 6, 16, 16, 3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 11, 16, 16, 13, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 1, 16, 16, 16, 16, 12, 16, 16, 2, 16, 16, 16, 16, 16, 12, 16, 3, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 6, 16, 16, 16, 16, 16, 16, 16, 12, 16, 16, 16, 16, 3, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 1, 16, 16, 16, 16, 8, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 6, 16, 16, 16, 16, 16, 16, 16, 3, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 1, 16, 16, 16, 12, 16, 16, 8, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 1, 16, 12, 16, 3, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 17, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 1, 16, 8, 5, 5, 5, 5, 5, 5, 6, 16, 16, 16, 16, 12, 16, 16, 16, 3, 5, 17, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 17, 5, 17, 5, 17, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 6, 16, 16, 16, 8, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 11, 16, 8, 5, 17, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 17, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 11, 16, 12, 16, 16, 16, 16, 16, 16, 12, 16, 16, 16, 16, 2, 16, 16, 16, 12, 16, 13, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 11, 16, 16, 13, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 17, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 1, 2, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 13, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 11, 13, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
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
      height = 40,
      id = 3,
      name = "Numbers",
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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
      id = 2,
      name = "Blocks",
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
          id = 10,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 608,
          y = 704,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 13,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 640,
          y = 416,
          width = 256,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 14,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 864,
          y = 448,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 20,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 192,
          y = 576,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 23,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 256,
          y = 160,
          width = 32,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 24,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 672,
          y = 160,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 25,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 960,
          y = 768,
          width = 64,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 26,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 128,
          y = 640,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 27,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 256,
          y = 448,
          width = 96,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 28,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 384,
          y = 448,
          width = 64,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 29,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 736,
          y = 608,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 30,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 928,
          y = 640,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 31,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 928,
          y = 544,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 32,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 192,
          y = 672,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 33,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 256,
          y = 672,
          width = 192,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 34,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 480,
          y = 672,
          width = 320,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 35,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 96,
          y = 320,
          width = 32,
          height = 352,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 36,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 352,
          y = 320,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 37,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 448,
          y = 416,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 38,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 448,
          y = 608,
          width = 32,
          height = 96,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 39,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 800,
          y = 544,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 40,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 832,
          y = 608,
          width = 128,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 41,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 640,
          y = 352,
          width = 384,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 43,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 608,
          y = 416,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 44,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 544,
          y = 160,
          width = 32,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 45,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 672,
          y = 224,
          width = 128,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 46,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 608,
          y = 320,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 47,
          name = "three",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 160,
          y = 576,
          width = 32,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 3,
            ["invert"] = true
          }
        },
        {
          id = 48,
          name = "three",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 448,
          y = 576,
          width = 320,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 3,
            ["invert"] = true
          }
        },
        {
          id = 49,
          name = "three",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 448,
          y = 384,
          width = 192,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 3,
            ["invert"] = true
          }
        },
        {
          id = 50,
          name = "three",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 96,
          y = 288,
          width = 544,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 3,
            ["invert"] = true
          }
        },
        {
          id = 51,
          name = "three",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 256,
          y = 128,
          width = 544,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 3,
            ["invert"] = true
          }
        },
        {
          id = 52,
          name = "three",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 768,
          y = 160,
          width = 32,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 3,
            ["invert"] = true
          }
        },
        {
          id = 53,
          name = "three",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 864,
          y = 192,
          width = 32,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 3,
            ["invert"] = true
          }
        },
        {
          id = 54,
          name = "four",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 224,
          y = 448,
          width = 32,
          height = 256,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 4,
            ["invert"] = true
          }
        },
        {
          id = 55,
          name = "four",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 800,
          y = 512,
          width = 160,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 4,
            ["invert"] = true
          }
        },
        {
          id = 56,
          name = "five",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 160,
          y = 64,
          width = 416,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 5,
            ["invert"] = true
          }
        },
        {
          id = 57,
          name = "five",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 1024,
          y = 352,
          width = 32,
          height = 448,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 5,
            ["invert"] = true
          }
        },
        {
          id = 58,
          name = "two",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 544,
          y = 96,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 2,
            ["invert"] = true
          }
        },
        {
          id = 59,
          name = "ones",
          type = "cdn_catwalk",
          shape = "rectangle",
          x = 800,
          y = 192,
          width = 64,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["div"] = 1,
            ["invert"] = true
          }
        },
        {
          id = 60,
          name = "start",
          type = "cdn_start",
          shape = "rectangle",
          x = 416,
          y = 832,
          width = 160,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {
            ["mode"] = "manual"
          }
        },
        {
          id = 63,
          name = "step",
          type = "cdn_step",
          shape = "rectangle",
          x = 49.3333,
          y = 21.3333,
          width = 1174.67,
          height = 800,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
