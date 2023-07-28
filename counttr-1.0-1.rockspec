package = "mfr"
version = "1.0-1"
source = {
   url = "git+https://github.com/mb6ockatf/counttr.git"
}
description = {
   summary = "mathematics count trainer",
   homepage = "https://mb6ockatf.github.io/counttr",
   license = "AGPL-3.0"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      main = "main.lua"
   }
}