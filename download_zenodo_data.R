library(httr)

dest_dir <- "data"

# List of Zenodo files to download
files <- list(
    "monitor_pm25_with_cmaq.rds" = "https://zenodo.org/record/14996970/files/monitor_pm25_with_cmaq.rds?download=1",
    "monitor_pm25_with_aod.rds" = "https://zenodo.org/record/14996970/files/monitor_pm25_with_aod.rds?download=1",
    "cmaq_for_predictions.rds" = "https://zenodo.org/record/14996970/files/cmaq_for_predictions.rds?download=1",
    "aod_for_predictions.rds" = "https://zenodo.org/record/14996970/files/aod_for_predictions.rds?download=1"
)

# Download files if not already present
for (filename in names(files)) {
    file_path <- file.path(dest_dir, filename)
    
    if (!file.exists(file_path)) {
        message("Downloading ", filename, "...")
        response <- GET(files[[filename]], write_disk(file_path, overwrite = TRUE), timeout(300))
        
        if (http_error(response)) {
            stop("Failed to download ", filename, ": HTTP ", status_code(response))
        }
    } else {
        message(filename, " already exists. Skipping download.")
    }
}
