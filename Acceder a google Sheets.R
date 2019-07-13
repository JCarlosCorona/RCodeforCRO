if (!require("pacman")) install.packages("pacman")
pacman::p_load("googlesheets")

gs_auth(new_user = FALSE)
for_gs <- gs_key("1akXns4D7qd1ooc913nHrh68Cuf65I68OAxcjdsmRH08")
for_gs_sheet <- gs_read(for_gs, ws = "DATA")
head(for_gs_sheet)

