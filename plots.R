library(tidyverse)
library(patchwork)
theme_classic2 <- function() {
  theme_classic() +
  theme(panel.border = element_rect(colour = "black", fill = NA, linewidth = 1))
}
theme_set(theme_classic2())


monitor_pm25_with_cmaq <- readRDS("data/monitor_pm25_with_cmaq.rds")
monitor_pm25_with_aod <- readRDS("data/monitor_pm25_with_aod.rds")

cmaq_fit <- readRDS("fits/cmaq_fit.rds")
cmaq_fit_cv <- readRDS("fits/cmaq_fit_cv.rds")
aod_fit <- readRDS("fits/aod_fit.rds")
aod_fit_cv <- readRDS("fits/aod_fit_cv.rds")
cmaq_for_predictions <- readRDS("data/cmaq_for_predictions.rds")
cmaq_pred <- readRDS("fits/cmaq_pred.rds")
aod_for_predictions <- readRDS("data/aod_for_predictions.rds")
aod_pred <- readRDS("fits/aod_pred.rds")
ensemble_fit <- readRDS("fits/ensemble_fit.rds")
weight_preds <- readRDS("fits/weight_preds.rds")
results <- readRDS("fits/results.rds")
ensemble_preds_at_observations <- readRDS("fits/ensemble_preds_at_observations.rds")



# Data - study area calculations 
range(cmaq_for_predictions$longitude)
range(cmaq_for_predictions$latitude)
range(aod_for_predictions$longitude)
range(aod_for_predictions$latitude)

# Data - temporal range
range(monitor_pm25_with_cmaq$date)
range(monitor_pm25_with_cmaq$date)

# Number of grid cells
length(unique(cmaq_for_predictions$space_id))
length(unique(aod_for_predictions$space_id))


# Data - number of monitors
length(unique(monitor_pm25_with_cmaq$space_id))

monitor_pm25_with_cmaq |>
    count(space_id, date) |>
    count(date)

monitor_pm25_with_aod |>
    count(space_id, date) |>
    count(date)


#######################
### Study Area Plot ###
#######################
# Data - study area plot
ca_map <- map_data("state") %>%
  filter(region == "california")

# Define the coordinates for the dotted square
minlon <- min(cmaq_for_predictions$longitude)
maxlon <- max(cmaq_for_predictions$longitude)
minlat <- min(cmaq_for_predictions$latitude)
maxlat <- max(cmaq_for_predictions$latitude)
square <- data.frame(
    long = c(minlon, maxlon, maxlon, minlon, minlon),
    lat = c(minlat, minlat, maxlat, maxlat, minlat)
)


data_plt <- ggplot() +
  geom_polygon(data = ca_map, 
               aes(x = long, y = lat, group = group),
               fill = NA, color = "black") +
  geom_path(data = square, 
            aes(x = long, y = lat, color = "Study Area", linetype = "Study Area"), 
            linewidth = 1) +
#  geom_text(aes(x = -117.15, y = 34.05, label = "Los Angeles"), 
#            size = 4) +
#  geom_point(aes(x = -118.25, y = 34.05)) +
  geom_point(data = monitor_pm25_with_cmaq |> 
               distinct(longitude, latitude),
             aes(x = longitude, y = latitude, color = "Monitor Location"), 
             shape = 2,  # Triangle shape
             size = 1) +
  labs(x = "Longitude", 
       y = "Latitude",
       color = NULL) +  # Title for the color and linetype legend
  scale_color_manual(values = c("Study Area" = "red", 
                                "Monitor Location" = "blue2")) +
  scale_linetype_manual(guide = "none", values = "dotted") +
  theme(legend.position = "inside",
        legend.position.inside = c(0.915, 0.94),  # Adjust these values to move the legend
        legend.justification.inside = c(0.9, 0.9),  # Anchors the legend at the top right
        legend.background = element_rect(fill = "white", colour = "black"))


scale_factor <- 0.6
ggsave(
    "figures_tables/studyarea.png", 
    data_plt, 
    width = 6 * scale_factor,
    height = 6 * scale_factor,
    dpi = 600
)


full_cmaq_preds <- cmaq_for_predictions |>
    left_join(cmaq_pred, by = c("time_id" = "time.id", 
                                "space_id" = "space.id", 
                                "spacetime_id" = "spacetime.id"))
full_aod_preds <- aod_for_predictions |>
    left_join(aod_pred, by = c("time_id" = "time.id", 
                                "space_id" = "space.id", 
                                "spacetime_id" = "spacetime.id"))
                                 


####################
### Stage 2 Plot ###
####################
date_use <- "2018-07-15"
one_day_cmaq <- full_cmaq_preds |>
    filter(date == date_use,
           !is.na(estimate))
one_day_aod <- full_aod_preds |>
    filter(date == date_use,
           !is.na(estimate))

min_cmaq_pred <- min(one_day_cmaq$estimate, na.rm = TRUE)
min_aod_pred <- min(one_day_aod$estimate, na.rm = TRUE)
max_cmaq_pred <- max(one_day_cmaq$estimate, na.rm = TRUE)
max_aod_pred <- max(one_day_aod$estimate, na.rm = TRUE)

min_pred <- min(min_cmaq_pred, min_aod_pred)
max_pred <- max(max_cmaq_pred, max_aod_pred)

latbuffer <- 0
lonbuffer <- 0

cmaqpredplt <- full_cmaq_preds |>
    filter(date == date_use,
           !is.na(estimate)) |>
    ggplot(aes(x = longitude, y = latitude, colour = estimate)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_tile(linewidth = .5) +
    scale_color_viridis_c(limits = c(min_pred, max_pred), breaks = seq(5, 20, by = 5)) +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(title = "CTM-Based PM2.5 Predictions",
         x = "Longitude",
         y = "Latitude",
         colour = "PM2.5 Prediction") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

cmaqorigplt <- full_cmaq_preds |>
    filter(date == date_use) |>
    ggplot(aes(x = longitude, y = latitude, colour = cmaq)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_tile(linewidth = .5) +
    scale_color_viridis_c() +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(title = "Observed CTM",
         x = "Longitude",
         y = "Latitude",
         colour = "CTM") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

aodpredplt <- full_aod_preds |>
    filter(date == date_use,
           !is.na(estimate)) |>
    ggplot(aes(x = longitude, y = latitude, colour = estimate)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_tile(linewidth = .5) +
    scale_color_viridis_c(limits = c(min_pred, max_pred), breaks = seq(5, 20, by = 5)) +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(title = "AOD-Based PM2.5 Predictions",
         x = "Longitude",
         y = "Latitude",
         colour = "PM2.5 Prediction") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

aodorigplt <- full_aod_preds |>
    filter(date == date_use) |>
    ggplot(aes(x = longitude, y = latitude, colour = aod)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_tile(linewidth = .5) +
    scale_color_viridis_c() +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(title = "Observed AOD",
         x = "Longitude",
         y = "Latitude",
         colour = "AOD") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

#join 4 plots
stage2plt <- (cmaqpredplt + cmaqorigplt + aodpredplt + aodorigplt) + 
    plot_layout(ncol = 2, byrow = T) +
    plot_annotation(tag_levels = "A")

scale_factor <- 0.6
ggsave(
    "figures_tables/stage2.png", 
    stage2plt, 
    width = 11 * scale_factor,
    height = 12 * scale_factor,
    dpi = 600
)

####################
### Stage 4 Plot ###
####################

one_day_monitor_pm25_with_cmaq <- monitor_pm25_with_cmaq |>
    filter(date == date_use)

one_day_cmaq_est <- monitor_pm25_with_cmaq |>
    left_join(cmaq_fit_cv, 
              by = c("time_id" = "time.id", 
                     "space_id" = "space.id", 
                     "spacetime_id" = "spacetime.id")) |>
    filter(date == date_use)

one_day_aod_est <- monitor_pm25_with_aod |>
    left_join(aod_fit_cv,
              by = c("time_id" = "time.id", 
                     "space_id" = "space.id", 
                     "spacetime_id" = "spacetime.id")) |>
    filter(date == date_use)

min_monitor_pm25 <- min(one_day_monitor_pm25_with_cmaq$pm25, na.rm = TRUE)
min_cmaq_est <- min(one_day_cmaq_est$estimate, na.rm = TRUE)
min_aod_est <- min(one_day_aod_est$estimate, na.rm = TRUE)
max_monitor_pm25 <- max(one_day_monitor_pm25_with_cmaq$pm25, na.rm = TRUE)
max_cmaq_est <- max(one_day_cmaq_est$estimate, na.rm = TRUE)
max_aod_est <- max(one_day_aod_est$estimate, na.rm = TRUE)

min_est <- min(min_monitor_pm25, min_cmaq_est, min_aod_est)
max_est <- max(max_monitor_pm25, max_cmaq_est, max_aod_est)


size_use <- 2.5
stage4aplt <- one_day_monitor_pm25_with_cmaq |>
    ggplot(aes(x = longitude, y = latitude, colour = pm25)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = size_use) +
    scale_color_viridis_c(limits = c(min_est, max_est), breaks = seq(5, 15, by = 5)) +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(x = "Longitude",
         y = "Latitude",
         colour = "PM2.5",
         title = "PM2.5 Monitor Observation") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

stage4bplt <- one_day_cmaq_est |>
    ggplot(aes(x = longitude, y = latitude, colour = estimate)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = size_use) +
    scale_color_viridis_c(limits = c(min_est, max_est), breaks = seq(5, 15, by = 5)) +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(x = "Longitude",
            y = "Latitude",
            colour = "PM2.5 Prediction",
            title = "CMAQ-Based PM2.5 Estimate") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

stage4cplt <- one_day_aod_est |>
    ggplot(aes(x = longitude, y = latitude, colour = estimate)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = size_use) +
    scale_color_viridis_c(limits = c(min_est, max_est), breaks = seq(5, 15, by = 5)) +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(x = "Longitude",
         y = "Latitude",
         colour = "PM2.5 Estimate",
         title = "AOD-Based PM2.5 Estimate") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

ensemble_weights <- 1 / (exp(-ensemble_fit$q[, 2:ncol(ensemble_fit$q)]) + 1)
ensemble_weights <- apply(ensemble_weights, 1, mean)
ensemble_fit_post <- data.frame(ensemble_weights = ensemble_weights,
                                space_id = ensemble_fit$q$space.id)

stage4dplt <- monitor_pm25_with_cmaq |>
    left_join(ensemble_fit_post, by = "space_id") |>
    filter(date == date_use) |>
    ggplot(aes(x = longitude, y = latitude, colour = ensemble_weights)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = size_use) +
    scale_color_viridis_c(limits = c(0.2, 1), breaks = seq(0.4, 0.8, by = 0.2)) +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(x = "Longitude",
         y = "Latitude",
         colour = "Weight Estimate",
         title = "Ensemble Weight Estimate") +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")


stage4plt <- (stage4aplt + stage4bplt + stage4cplt + stage4dplt) +
    plot_layout(ncol = 2, byrow = T) +
    plot_annotation(tag_levels = "A")

scale_factor <- 0.6
ggsave(
    "figures_tables/stage4.png", 
    stage4plt, 
    width = 11 * scale_factor, 
    height = 12 * scale_factor,
    dpi = 600
)


######################
### Stage 5/6 Plot ###
######################




weights_w_locs <- weight_preds$locations
weights_tr <- 1 / (exp(-weight_preds$q) + 1)
weights_w_locs$weights <- apply(weights_tr, 1, mean)


s56_cplt <- weights_w_locs |>
    left_join(cmaq_for_predictions |>
                distinct(space_id, longitude, latitude), 
            by = c("space.id" = "space_id")) |>
    ggplot(aes(x = longitude, y = latitude, colour = weights)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = .0001) +
    labs(x = "Longitude",
         y = "Latitude",
         colour = "Weight Estimate",
         title = "Ensemble Weight") +
    scale_color_viridis_c() +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")




locs <- distinct(cmaq_for_predictions[, c("space_id", "latitude", "longitude")])
dates <- distinct(cmaq_for_predictions[, c("time_id", "date")])

full_results <- cmaq_pred
full_results$estimate <- results$ensemble.estimate
full_results$sd <- results$ensemble.sd

full_results <- full_results |>
    left_join(locs, by = c("space.id" = "space_id")) |>
    left_join(dates, by = c("time.id" = "time_id"))

s56_dplt <- full_results |>
    filter(date == date_use) |>
    ggplot(aes(x = longitude, y = latitude, colour = estimate)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = .0001) +
    labs(x = "Longitude",
         y = "Latitude",
         color = "PM2.5 Estimate",
         title = "Ensemble Mean") +
    scale_color_viridis_c() +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")

s56_eplt <- full_results |>
    filter(date == date_use) |>
    ggplot(aes(x = longitude, y = latitude, colour = sd)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = .0001) +
    labs(x = "Longitude",
         y = "Latitude",
         color = "PM2.5 SD",
         title = "Ensemble SD") +
    scale_color_viridis_c() +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    theme(legend.position = "bottom",
          legend.direction = "horizontal")



s56plt <- (s56_cplt + s56_dplt + s56_eplt) +
    plot_layout(ncol = 3, byrow = T) +
    plot_annotation(tag_levels = "A")


scale_factor <- 0.6
ggsave(
    "figures_tables/stage56.png", 
    s56plt, 
    width = 16 * scale_factor,
    height = 6 * scale_factor,
    dpi = 600
)


#########################
#######CV plot###########
#########################


cv_id_cmaq_ord <- ensembleDownscaleR::create_cv(
    time.id = monitor_pm25_with_cmaq$time_id, 
    space.id = monitor_pm25_with_cmaq$space_id,
    spacetime.id = monitor_pm25_with_cmaq$spacetime_id,
    type = "ordinary",
    num.folds = 5
)

cv_id_cmaq_spat <- ensembleDownscaleR::create_cv(
    time.id = monitor_pm25_with_cmaq$time_id, 
    space.id = monitor_pm25_with_cmaq$space_id,
    spacetime.id = monitor_pm25_with_cmaq$spacetime_id,
    type = "spatial",
    num.folds = 5
)

cv_id_cmaq_spatclus <- ensembleDownscaleR::create_cv(
    time.id = monitor_pm25_with_cmaq$time_id, 
    space.id = monitor_pm25_with_cmaq$space_id,
    spacetime.id = monitor_pm25_with_cmaq$spacetime_id,
    type = "spatial_clustered",
    coords = monitor_pm25_with_cmaq[, c("x", "y")],
    num.folds = 5
)


cv_id_cmaq_spatbuff <- ensembleDownscaleR::create_cv(
    time.id = monitor_pm25_with_cmaq$time_id, 
    space.id = monitor_pm25_with_cmaq$space_id,
    spacetime.id = monitor_pm25_with_cmaq$spacetime_id,
    type = "spatial_buffered",
    coords = monitor_pm25_with_cmaq[, c("x", "y")],
    buffer.size = 30,
    num.folds = 5
)


full_ord <- monitor_pm25_with_cmaq
full_ord$cv_id <- cv_id_cmaq_ord$cv.id
full_ord$cv_type <- "Ordinary"
full_spat <- monitor_pm25_with_cmaq
full_spat$cv_id <- cv_id_cmaq_spat$cv.id
full_spat$cv_type <- "Spatial"
full_spatclus <- monitor_pm25_with_cmaq
full_spatclus$cv_id <- cv_id_cmaq_spatclus$cv.id
full_spatclus$cv_type <- "Spatial Clustered"
full_spatbuff <- monitor_pm25_with_cmaq
full_spatbuff$cv_id <- cv_id_cmaq_spatbuff$cv.id
full_spatbuff$cv_id <- as.character(full_spatbuff$cv_id)
full_spatbuff$cv_id <- ifelse(full_spatbuff$cv_id == "1", "1", "2-5")
full_spatbuff$cv_id <- ifelse(cv_id_cmaq_spatbuff$drop.matrix[, 1] == 1, "Dropped", full_spatbuff$cv_id)
full_spatbuff$cv_type <- "Spatial Buffered"


date_counts <- table(full_ord$date)
date_for_cv <- sample(names(date_counts[which(date_counts >= 59)]), 4)
full_cv <- rbind(full_ord, full_spat, full_spatclus, full_spatbuff) |>
    filter(date %in% date_for_cv)


cv_ex_plt <- full_cv |>
    mutate(cv_id = factor(cv_id, levels = c("1", "2", "3", "4", "5", "2-5", "Dropped"))) |>
    ggplot(aes(x = longitude, y = latitude, color = cv_id)) +
    geom_polygon(data = ca_map, 
                 aes(x = long, y = lat, group = group),
                 fill = NA, color = "black") +
    geom_point(size = 2) +
    facet_grid(cv_type ~ date) +
    scale_color_viridis_d() +
    coord_cartesian(xlim = c(minlon - lonbuffer, maxlon + lonbuffer), 
                    ylim = c(minlat - latbuffer, maxlat + latbuffer)) +
    labs(x = "Longitude",
         y = "Latitude",
         color = "CV Assignment")

scale_factor <- 0.8
ggsave(
    "figures_tables/cv.png", 
    cv_ex_plt, 
    width = 11 * scale_factor,
    height = 9 * scale_factor,
    dpi = 600
)
