# prior to running code, download "MoviesonStreamingPlatforms2.csv" into documents

df = readr::read_csv("MoviesOnStreamingPlatforms2.csv")
df = df |> dplyr::select(2:11)
head(df)


missing_values_by_column <- colSums(is.na(df))
missing_values_by_column
missing_values_indices <- which(is.na(df$`Rotten Tomatoes`))
print(missing_values_indices)
rows_to_remove <- c(3689, 3690, 3691, 3692, 3693, 3694, 3695)

data_frame_cleaned <- df[-rows_to_remove, ]
missing_values_by_column <- colSums(is.na(data_frame_cleaned))



df_long = data_frame_cleaned |> tidyr::pivot_longer(
  cols = 6:9,
  names_to = 'service',
  values_to = 'yes/no'
) |> dplyr::select(-Type) |> 
  janitor::clean_names() 

df_long = df_long  |> 
  dplyr::mutate(
    rotten_tomatoes_cat = dplyr::case_when(
      rotten_tomatoes < 10 ~ '0-10',
      rotten_tomatoes < 20 & rotten_tomatoes >= 10 ~ '10-20',
      rotten_tomatoes < 30 & rotten_tomatoes >= 20 ~ '20-30',
      rotten_tomatoes < 40 & rotten_tomatoes >= 30 ~ '30-40',
      rotten_tomatoes < 50 & rotten_tomatoes >= 40 ~ '40-50',
      rotten_tomatoes < 60 & rotten_tomatoes >= 50 ~ '50-60',
      rotten_tomatoes < 70 & rotten_tomatoes >= 60 ~ '60-70',
      rotten_tomatoes < 80 & rotten_tomatoes >= 70 ~ '70-80',
      rotten_tomatoes < 90 & rotten_tomatoes >= 80 ~ '80-90',
      rotten_tomatoes < 100 & rotten_tomatoes >= 90 ~ '90-100',
    )
  )

write.csv(x = df_long, "MoviesOnStreamingPlatformsLong.csv")
