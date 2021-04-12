# Render CVs
# Knit the HTML version
rmarkdown::render("static/pagedown-html/cv.Rmd", output_file = "static/pagedown-html/cv.html")
# Knit the PDF version
tmp_html_cv_loc <- fs::file_temp(ext = ".html")
rmarkdown::render("static/pagedown-pdf/cv.Rmd", output_file = tmp_html_cv_loc, params = list(pdf_mode = TRUE))
pagedown::chrome_print(input = tmp_html_cv_loc, output = "static/pagedown-pdf/cv.pdf")

# blogdown::build_dir("static")
