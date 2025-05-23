
library(ensembleDownscaleR)
set.seed(42)

# start timer
start_time <- proc.time()



###############
### Stage 1 ###
###############

n.iter <- 25e3
burn <- 5e3
thin <- 20

n.iter.pred <- 1e3

monitor_pm25_with_cmaq <- readRDS("data/monitor_pm25_with_cmaq.rds")

cmaq_fit <- grm(
    Y = monitor_pm25_with_cmaq$pm25,
    X = monitor_pm25_with_cmaq$cmaq,
    L = monitor_pm25_with_cmaq[, c("elevation", "population")],
    M = monitor_pm25_with_cmaq[, c("cloud", "v_wind", "hpbl", 
                                   "u_wind", "short_rf", "humidity_2m")],
    n.iter = n.iter,
    burn = burn,
    thin = thin,
    covariance = "matern",
    matern.nu = 0.5,
    coords = monitor_pm25_with_cmaq[, c("x", "y")],
    space.id = monitor_pm25_with_cmaq$space_id,
    time.id = monitor_pm25_with_cmaq$time_id,
    spacetime.id = monitor_pm25_with_cmaq$spacetime_id,
    verbose.iter = 10
)
saveRDS(cmaq_fit, "fits/cmaq_fit.rds")


monitor_pm25_with_aod <- readRDS("data/monitor_pm25_with_aod.rds")

aod_fit <- grm(
    Y = monitor_pm25_with_aod$pm25,
    X = monitor_pm25_with_aod$aod,
    L = monitor_pm25_with_aod[, c("elevation", "population")],
    M = monitor_pm25_with_aod[, c("cloud", "v_wind", "hpbl", 
                                   "u_wind", "short_rf", "humidity_2m")],
    n.iter = n.iter,
    burn = burn,
    thin = thin,
    coords = monitor_pm25_with_aod[, c("x", "y")],
    space.id = monitor_pm25_with_aod$space_id,
    time.id = monitor_pm25_with_aod$time_id,
    spacetime.id = monitor_pm25_with_aod$spacetime_id,
    verbose.iter = 10
)
saveRDS(aod_fit, "fits/aod_fit.rds")



###############
### Stage 2 ###
###############

cmaq_for_predictions <- readRDS("data/cmaq_for_predictions.rds")


cmaq_pred <- grm_pred(
    grm.fit = cmaq_fit,
    X = cmaq_for_predictions$cmaq,
    L = cmaq_for_predictions[, c("elevation", "population")],
    M = cmaq_for_predictions[, c("cloud", "v_wind", "hpbl",
                                 "u_wind", "short_rf", "humidity_2m")],
    coords = cmaq_for_predictions[, c("x", "y")],
    space.id = cmaq_for_predictions$space_id,
    time.id = cmaq_for_predictions$time_id,
    spacetime.id = cmaq_for_predictions$spacetime_id,
    n.iter = n.iter.pred,
    verbose = T
)

saveRDS(cmaq_pred, "fits/cmaq_pred.rds")



aod_for_predictions <- readRDS("data/aod_for_predictions.rds")

aod_pred <- grm_pred(
    grm.fit = aod_fit,
    X = aod_for_predictions$aod,
    L = aod_for_predictions[, c("elevation", "population")],
    M = aod_for_predictions[, c("cloud", "v_wind", "hpbl", 
                                        "u_wind", "short_rf", "humidity_2m")],
    coords = aod_for_predictions[, c("x", "y")],
    space.id = aod_for_predictions$space_id,
    time.id = aod_for_predictions$time_id,
    spacetime.id = aod_for_predictions$spacetime_id,
    n.iter = n.iter.pred,
    verbose = T
)

saveRDS(aod_pred, "fits/aod_pred.rds")



###############
### Stage 3 ###
###############

cv_id_cmaq_ord <- create_cv(
    time.id = monitor_pm25_with_cmaq$time_id, 
    space.id = monitor_pm25_with_cmaq$space_id,
    spacetime.id = monitor_pm25_with_cmaq$spacetime_id,
    type = "ordinary"
)
saveRDS(cv_id_cmaq_ord, "fits/cv_id_cmaq_ord.rds")


cmaq_fit_cv <- grm_cv(
    Y = monitor_pm25_with_cmaq$pm25,
    X = monitor_pm25_with_cmaq$cmaq,
    cv.object = cv_id_cmaq_ord,
    L = monitor_pm25_with_cmaq[, c("elevation", "population")],
    M = monitor_pm25_with_cmaq[, c("cloud", "v_wind", "hpbl", 
                                   "u_wind", "short_rf", "humidity_2m")],
    n.iter = n.iter,
    burn = burn,
    thin = thin,
    coords = monitor_pm25_with_cmaq[, c("x", "y")],
    space.id = monitor_pm25_with_cmaq$space_id,
    time.id = monitor_pm25_with_cmaq$time_id,
    spacetime.id = monitor_pm25_with_cmaq$spacetime_id,
    verbose.iter = 10
)
saveRDS(cmaq_fit_cv, "fits/cmaq_fit_cv.rds")


cv_id_aod_ord <- create_cv(
    time.id = monitor_pm25_with_aod$time_id,
    space.id = monitor_pm25_with_aod$space_id,
    spacetime.id = monitor_pm25_with_aod$spacetime_id,
    type = "ordinary"
)
saveRDS(cv_id_aod_ord, "fits/cv_id_aod_ord.rds")

aod_fit_cv <- grm_cv(
    Y = monitor_pm25_with_aod$pm25,
    X = monitor_pm25_with_aod$aod,
    cv.object = cv_id_aod_ord,
    L = monitor_pm25_with_aod[, c("elevation", "population")],
    M = monitor_pm25_with_aod[, c("cloud", "v_wind", "hpbl", 
                                   "u_wind", "short_rf", "humidity_2m")],
    n.iter = n.iter,
    burn = burn,
    thin = thin,
    coords = monitor_pm25_with_aod[, c("x", "y")],
    space.id = monitor_pm25_with_aod$space_id,
    time.id = monitor_pm25_with_aod$time_id,
    spacetime.id = monitor_pm25_with_aod$spacetime_id,
    verbose.iter = 10
)
saveRDS(aod_fit_cv, "fits/aod_fit_cv.rds")



###############
### Stage 4 ###
###############

ensemble_fit <- ensemble_spatial(
    grm.fit.cv.1 = cmaq_fit_cv,
    grm.fit.cv.2 = aod_fit_cv,
    n.iter = n.iter,
    burn = burn,
    thin = thin,
    tau.a = 0.001,
    tau.b = 0.001,
    theta.tune = 0.2,
    theta.a = 5,
    theta.b = 0.05
)


saveRDS(ensemble_fit, "fits/ensemble_fit.rds")



##############
### Other ####
##############

ensemble_preds_at_observations <- gap_fill(
    grm.pred.1 = cmaq_fit_cv,
    grm.pred.2 = aod_fit_cv,
    weights = ensemble_fit
)

saveRDS(ensemble_preds_at_observations, "fits/ensemble_preds_at_observations.rds")




###############
### Stage 5 ###
###############

weight_preds <- weight_pred(
    ensemble.fit = ensemble_fit,
    coords = cmaq_for_predictions[, c("x", "y")],
    space.id = cmaq_for_predictions$space_id,
    verbose = T
)


saveRDS(weight_preds, "fits/weight_preds.rds")




###############
### Stage 6 ###
###############

results <- gap_fill(
    grm.pred.1 = cmaq_pred,
    grm.pred.2 = aod_pred,
    weights = weight_preds)

saveRDS(results, "fits/results.rds")

# stop timer
end_time <- proc.time()
total_runtime <- end_time - start_time
total_hours <- ((total_runtime[1] + total_runtime[2]) / 60) / 60
saveRDS(total_hours, "fits/total_hours.rds")


