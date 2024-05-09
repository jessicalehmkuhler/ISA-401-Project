# Function ----------------------------------------------------------------

scrape_stream = function(url){
  # lets import the HTML of the page into R
  input_page = rvest::read_html(url)
  
  streaming = input_page |>
    rvest::html_elements(css = "div.clearfix > div > h3 > b") |>
    rvest::html_text2() -> Streaming_Platform
  
  revenue = input_page |>
    rvest::html_elements(css = "div > p > b > i") |>
    rvest::html_text2() -> Estimated_2022_Revenue_Billion
  
  #Streaming_Platform <- Streaming_Platform[-3]
  #Estimated_2022_Revenue <- Estimated_2022_Revenue[-4]
  
  stream_df = tibble::tibble(Streaming_Platform, Estimated_2022_Revenue_Billion)
  
  return(stream_df)
}

# URLs will correspond to all departments
urls = c('https://www.insidermonkey.com/blog/15-biggest-streaming-and-tv-companies-in-the-us-1192787/','https://www.insidermonkey.com/blog/5-biggest-streaming-and-tv-companies-in-the-us-1192786/?singlepage=1')

stream_df = purrr::map_df(.x = urls, .f = scrape_stream)


# Cleaning and Tidying ----------------------------------------------------
# Fixing blank entries to align
stream_df[3, 1] = stream_df[4,1]
stream_df[4, 2] = NA
stream_df = na.omit(stream_df)

# Cleaning numbers in front of platforms
stream_df$Streaming_Platform <- stream_df$Streaming_Platform |>
  stringr::str_remove("^[0-9]+\\.\\s*")

# Cleaning fuboTV Inc.
stream_df$Streaming_Platform <- stream_df$Streaming_Platform |>
  stringr::str_remove("\\s*\\(NYSE:.*")

# Cleaning estimated revenue column
stream_df$Estimated_2022_Revenue_Billion <- stream_df$Estimated_2022_Revenue_Billion |>
  # Remove "Estimated 2022 Revenue:", "billion", and any non-numeric characters
  stringr::str_replace_all("Estimated 2022 Revenue:", "") |>
  stringr::str_replace_all("2022 Revenue:", "") |>
  stringr::str_replace_all("Revenue:", "") |>
  stringr::str_replace_all("\\$", "") |>
  stringr::str_replace_all(" billion", "")

# Changing revenue column to numeric
stream_df$Estimated_2022_Revenue_Billion<-as.numeric(stream_df$Estimated_2022_Revenue_Billion)

# Excel File --------------------------------------------------------------
if (!require(openxlsx)) install.packages("openxlsx")
library(openxlsx)
# Write into excel file
write.xlsx(stream_df, file = "StreamingPlatformScrape.xlsx")