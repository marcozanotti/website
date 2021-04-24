# Image  resizing

library(magick)

image_read("static/img/kite.jpg") %>%
  image_crop("1600x800!") %>%
  image_browse()

image_read("static/img/dispositionEffect_logo.png") %>%
  image_scale("250x250!") %>%
  image_write("static/img/de_250x250.png")
