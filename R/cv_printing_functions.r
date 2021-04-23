# Functions that create the CV

img_clean <- function(img_name = "cvpic.jpeg", img_path = "pics/", format = "png") {

  img_path %>%
    paste0(img_name) %>%
    magick::image_read() %>%
    magick::image_fill(color = "transparent", refcolor = "white", fuzz = 4, point = "+1+1") %>%
    magick::image_crop(geometry = magick::geometry_area(1500, 1850, 0, 0)) %>%
    magick::image_write(path = paste0(img_path, gsub("\\.\\w+", "_new\\.", img_name), format), format = format)

}
# img_clean()


create_cv_object <-  function(data_location) {

  cv <- list()

  is_google_sheets_location <- stringr::str_detect(data_location, "docs\\.google\\.com")
  if (!is_google_sheets_location) {
    stop("No google sheet location.", call. = FALSE)
  }

  googlesheets4::gs4_deauth()

  cv$experiences <- googlesheets4::read_sheet(data_location, sheet = "experiences", col_types = "c")
  cv$text_blocks <- googlesheets4::read_sheet(data_location, sheet = "text_blocks", col_types = "c")
  cv$skills <- googlesheets4::read_sheet(data_location, sheet = "skills", col_types = "c")
  cv$contacts <- googlesheets4::read_sheet(data_location, sheet = "contacts", col_types = "c")

  return(cv)

}


clean_cv_object <- function(cv, language = "en", resume = FALSE) {

  extract_year <- function(dates) {
    date_year <- stringr::str_extract(dates, "(20|19)[0-9]{2}")
    date_year[is.na(date_year)] <- lubridate::year(lubridate::ymd(Sys.Date())) + 10
    return(date_year)
  }

  parse_dates <- function(dates) {
    date_month <- stringr::str_extract(dates, "(\\w+|\\d+)(?=(\\s|\\/|-)(20|19)[0-9]{2})")
    date_month[is.na(date_month)] <- "1"
    date <- paste("1", date_month, extract_year(dates), sep = "-") %>%
      lubridate::dmy()
    return(date)
  }

  # clean experiences
  cv$experiences <- cv$experiences %>%
      tidyr::unite(
      tidyr::starts_with('bullet'),
      col = "description_bullets",
      sep = "\n- ",
      na.rm = TRUE
    ) %>%
    dplyr::mutate(
      description_bullets = ifelse(description_bullets != "", paste0("- ", description_bullets), ""),
      start = ifelse(start == "NULL", NA, start),
      end = ifelse(end == "NULL", NA, end),
      start_year = extract_year(start),
      end_year = extract_year(end),
      timeline = dplyr::case_when(
        is.na(start) & is.na(end)  ~ "N/A", # no start and no end
        is.na(start) & !is.na(end) ~ as.character(end), # no start but end
        !is.na(start) & is.na(end)  ~ paste("Current", "-", start), # start but no end
        TRUE ~ paste(end, "-", start) # start and end
      )
    ) %>%
    tidyr::unite(
      tidyr::starts_with('description'),
      col = "description",
      sep = "\n\n",
      na.rm = TRUE
    ) %>%
    dplyr::mutate_all(~ stringr::str_replace_all(., stringr::fixed("\\n"), stringr::fixed("\n"))) %>%
    dplyr::mutate_all(~ stringr::str_remove_all(., stringr::fixed("\n\n$"))) %>%
    dplyr::mutate_all(~ ifelse(is.na(.), 'N/A', .))

  # language
  cv$experiences <- cv$experiences %>%
    dplyr::filter(lang == language)
  cv$text_blocks <- cv$text_blocks %>%
    dplyr::filter(lang == language)
  cv$skills <- cv$skills %>%
    dplyr::filter(lang == language)

  if (resume) {
    cv$experiences <- cv$experiences %>%
      dplyr::filter(in_resume == TRUE)
  } else {
    cv$experiences <- cv$experiences %>%
      dplyr::filter(in_cv == TRUE)
  }

  return(cv)

}


print_experience <- function(cv, section_id){

  glue_template <- "
### {title}

{institution}

{loc}

{timeline}

{description}
\n\n\n"

  dplyr::filter(cv$experiences, section == section_id) %>%
    glue::glue_data(glue_template) %>%
    print()
  return(invisible(cv))

}


print_text_block <- function(cv, section_id){

  cv$text_blocks %>%
    dplyr::filter(section == section_id) %>%
    dplyr::pull(text) %>%
    stringr::str_replace_all(stringr::fixed("\\n"), stringr::fixed("\n")) %>%
    cat()
  return(invisible(cv))

}


print_skill_bars <- function(cv, section_id, out_of = 5, bar_color = "#969696", bar_background = "#d9d9d9"){

    glue_template <-
"
<div
  class = 'skill-bar'
  style = \"background:linear-gradient(to right, {bar_color} {width_percent}%, {bar_background} {width_percent}% 100%)\"
>{skill}</div>"

  cv$skills %>%
    dplyr::filter(section == section_id) %>%
    dplyr::mutate(level = as.numeric(stringr::str_replace_all(level, "\\,", "\\."))) %>%
    dplyr::arrange(desc(level)) %>%
    dplyr::mutate(width_percent = round(100 * level / out_of)) %>%
    glue::glue_data(glue_template) %>%
    print()
  return(invisible(cv))

}


print_contacts <- function(cv) {

  cv$contacts %>%
    glue::glue_data("- <i class='fa fa-{icon}'></i> {contact}") %>%
    print()
  return(invisible(cv))

}
