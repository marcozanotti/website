# Image  resizing

library(magick)

image_read("static/img/kite2.jpg") %>%
  image_crop("3800x2500!") %>%
  image_browse()

image_read("static/img/kite2.jpg") %>%
  image_crop(geometry_area(3400, 2000, 400, 700)) %>%
  image_browse()

image_read("static/img/kite2.jpg") %>%
  image_crop(geometry_area(3400, 2000, 400, 700)) %>%
  image_write("static/img/kite2.png", format = "png")

image_read("static/img/dispositionEffect_logo.png") %>%
  image_scale("250x250!") %>%
  image_write("static/img/de_250x250.png")

image_read("static/img/lapland.jpg") %>%
  image_crop(geometry_area(800, 650, 0, 50)) %>%
  image_write("static/img/lapland.png", format = "png")
