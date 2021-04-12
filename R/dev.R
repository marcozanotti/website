# Blogdown developments

# 1) initialize new git repo
# 2) create RStudio project with version control on the new repo
# 3) installs
install.packages("blogdown")
blogdown::install_hugo()

# 4) build new site with a specific theme
# https://themes.gohugo.io/

blogdown::new_site(theme = "rhazdon/hugo-theme-hello-friend-ng")

# 5) build
blogdown::build_site()

# 6) local preview
blogdown::serve_site()
