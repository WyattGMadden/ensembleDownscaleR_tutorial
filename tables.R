library(tidyverse)
library(patchwork)
theme_classic2 <- function() {
  theme_classic() +
  theme(panel.border = element_rect(colour = "black", fill = NA, linewidth = 1))
}
theme_set(theme_classic2())


cmaq_fit_cv <- readRDS("fits/cmaq_fit_cv.rds")
aod_fit_cv <- readRDS("fits/aod_fit_cv.rds")
ensemble_preds_at_observations <- readRDS("fits/ensemble_preds_at_observations.rds")

# comparison table results
aod_fit_cv_spat <- readRDS("fits/aod_fit_cv_spat.rds")
cmaq_fit_cv_spat <- readRDS("fits/cmaq_fit_cv_spat.rds")
ensemble_preds_at_observations_spat <- readRDS("fits/ensemble_preds_at_observations_spat.rds")
aod_fit_cv_spatclust <- readRDS("fits/aod_fit_cv_spatclust.rds")
cmaq_fit_cv_spatclust <- readRDS("fits/cmaq_fit_cv_spatclust.rds")
ensemble_preds_at_observations_spatclust <- readRDS("fits/ensemble_preds_at_observations_spatclust.rds")
aod_fit_cv_spatbuff3 <- readRDS("fits/aod_fit_cv_spatbuff3.rds")
cmaq_fit_cv_spatbuff3 <- readRDS("fits/cmaq_fit_cv_spatbuff3.rds")
ensemble_preds_at_observations_spatbuff3 <- readRDS("fits/ensemble_preds_at_observations_spatbuff3.rds")
aod_fit_cv_spatbuff7 <- readRDS("fits/aod_fit_cv_spatbuff7.rds")
cmaq_fit_cv_spatbuff7 <- readRDS("fits/cmaq_fit_cv_spatbuff7.rds")
ensemble_preds_at_observations_spatbuff7 <- readRDS("fits/ensemble_preds_at_observations_spatbuff7.rds")


####################
### Results Table###
####################


pred_obs_full <- ensemble_preds_at_observations |>
    left_join(cmaq_fit_cv[, c("time.id", "space.id", "spacetime.id", "obs","estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(cmaq.estimate = estimate,
           cmaq.sd = sd) |>
    select(-estimate, -sd) |>
    left_join(aod_fit_cv[, c("time.id", "space.id", "spacetime.id", "estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(aod.estimate = estimate,
           aod.sd = sd) |>
    select(-estimate, -sd) |>
    filter(!is.na(ensemble.estimate),
           !is.na(cmaq.estimate),
           !is.na(aod.estimate)) |>
    pivot_longer(cols = c(ensemble.estimate, cmaq.estimate, aod.estimate, 
                          ensemble.sd, cmaq.sd, aod.sd), 
                 names_to = c("type", ".value"),
                 names_pattern = "(.*)\\.(.*)"
  )

pred_obs_full_spat <- ensemble_preds_at_observations_spat |>
    left_join(cmaq_fit_cv_spat[, c("time.id", "space.id", "spacetime.id", "obs","estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(cmaq.estimate = estimate,
           cmaq.sd = sd) |>
    select(-estimate, -sd) |>
    left_join(aod_fit_cv_spat[, c("time.id", "space.id", "spacetime.id", "estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(aod.estimate = estimate,
           aod.sd = sd) |>
    select(-estimate, -sd) |>
    filter(!is.na(ensemble.estimate),
           !is.na(cmaq.estimate),
           !is.na(aod.estimate)) |>
    pivot_longer(cols = c(ensemble.estimate, cmaq.estimate, aod.estimate, 
                          ensemble.sd, cmaq.sd, aod.sd), 
                 names_to = c("type", ".value"),
                 names_pattern = "(.*)\\.(.*)"
  )

pred_obs_full_spatclust <- ensemble_preds_at_observations_spatclust |>
    left_join(cmaq_fit_cv_spatclust[, c("time.id", "space.id", "spacetime.id", "obs","estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(cmaq.estimate = estimate,
           cmaq.sd = sd) |>
    select(-estimate, -sd) |>
    left_join(aod_fit_cv_spatclust[, c("time.id", "space.id", "spacetime.id", "estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(aod.estimate = estimate,
           aod.sd = sd) |>
    select(-estimate, -sd) |>
    filter(!is.na(ensemble.estimate),
           !is.na(cmaq.estimate),
           !is.na(aod.estimate)) |>
    pivot_longer(cols = c(ensemble.estimate, cmaq.estimate, aod.estimate, 
                          ensemble.sd, cmaq.sd, aod.sd), 
                 names_to = c("type", ".value"),
                 names_pattern = "(.*)\\.(.*)"
  )

pred_obs_full_spatbuff3 <- ensemble_preds_at_observations_spatbuff3 |>
    left_join(cmaq_fit_cv_spatbuff3[, c("time.id", "space.id", "spacetime.id", "obs","estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(cmaq.estimate = estimate,
           cmaq.sd = sd) |>
    select(-estimate, -sd) |>
    left_join(aod_fit_cv_spatbuff3[, c("time.id", "space.id", "spacetime.id", "estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(aod.estimate = estimate,
           aod.sd = sd) |>
    select(-estimate, -sd) |>
    filter(!is.na(ensemble.estimate),
           !is.na(cmaq.estimate),
           !is.na(aod.estimate)) |>
    pivot_longer(cols = c(ensemble.estimate, cmaq.estimate, aod.estimate, 
                          ensemble.sd, cmaq.sd, aod.sd), 
                 names_to = c("type", ".value"),
                 names_pattern = "(.*)\\.(.*)"
  )

pred_obs_full_spatbuff7 <- ensemble_preds_at_observations_spatbuff7 |>
    left_join(cmaq_fit_cv_spatbuff7[, c("time.id", "space.id", "spacetime.id", "obs","estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(cmaq.estimate = estimate,
           cmaq.sd = sd) |>
    select(-estimate, -sd) |>
    left_join(aod_fit_cv_spatbuff7[, c("time.id", "space.id", "spacetime.id", "estimate", "sd")],
              by = c("time.id", "space.id", "spacetime.id")) |>
    mutate(aod.estimate = estimate,
           aod.sd = sd) |>
    select(-estimate, -sd) |>
    filter(!is.na(ensemble.estimate),
           !is.na(cmaq.estimate),
           !is.na(aod.estimate)) |>
    pivot_longer(cols = c(ensemble.estimate, cmaq.estimate, aod.estimate, 
                          ensemble.sd, cmaq.sd, aod.sd), 
                 names_to = c("type", ".value"),
                 names_pattern = "(.*)\\.(.*)"
  )

pred_obs_full$cv <- "Ordinary"
pred_obs_full_spat$cv <- "Spatial"
pred_obs_full_spatclust$cv <- "Spatial Clustered"
pred_obs_full_spatbuff3$cv <- "Spatial Buffered (0.3 Corr)"
pred_obs_full_spatbuff7$cv <- "Spatial Buffered (0.7 Corr)"

pred_obs_all <- rbind(
    pred_obs_full, 
    pred_obs_full_spat,
    pred_obs_full_spatclust,
    pred_obs_full_spatbuff3,
    pred_obs_full_spatbuff7
  )


pred_obs_full_metrics_table <- pred_obs_all |>
    mutate(lower = estimate - 1.96 * sd,
           upper = estimate + 1.96 * sd) |>
    group_by(cv, type) |>
    summarise(
        rmse = sqrt(mean((estimate - obs)^2)),
        R2 = 1 - sum((obs - estimate)^2) / sum((obs - mean(obs))^2),
        avg_sd = mean(sd),
        coverage = mean((lower <= obs) & (upper >= obs))
    ) |>
    mutate(type = case_when(
        type == "ensemble" ~ "Ensemble Model",
        type == "cmaq" ~ "CMAQ-Based Model",
        type == "aod" ~ "AOD-Based Model"
        )
    ) |>
    rename("Cross-Validation" = cv,
           "Model" = type,
           "RMSE" = rmse,
           "R^2" = R2,
           "Average Posterior SD" = avg_sd,
           "Coverage of 95% PI" = coverage) |>
    knitr::kable("latex", digits = 3)




writeLines(
    pred_obs_full_metrics_table, 
    "figures_tables/pred_obs_full_metrics_table.tex"
)


###############
### Runtime ###
###############

minutestime <- runtime['elapsed'] / 60
hourstime <- minutestime / 60









