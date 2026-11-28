library(airGR)

## GR4J run on the bundled example catchment (from ?RunModel_GR4J)
data(L0123001)
InputsModel <- CreateInputsModel(FUN_MOD = RunModel_GR4J, DatesR = BasinObs$DatesR,
                                 Precip = BasinObs$P, PotEvap = BasinObs$E)
Ind_Run <- seq(which(format(BasinObs$DatesR, format = "%Y-%m-%d") == "1990-01-01"),
               which(format(BasinObs$DatesR, format = "%Y-%m-%d") == "1999-12-31"))
RunOptions <- CreateRunOptions(FUN_MOD = RunModel_GR4J, InputsModel = InputsModel,
                               IndPeriod_Run = Ind_Run)
Param <- c(X1 = 257.238, X2 = 1.012, X3 = 88.235, X4 = 2.208)
OutputsModel <- RunModel_GR4J(InputsModel = InputsModel, RunOptions = RunOptions, Param = Param)

stopifnot(length(OutputsModel$Qsim) == length(Ind_Run))
stopifnot(all(is.finite(OutputsModel$Qsim)))
stopifnot(all(OutputsModel$Qsim >= 0))
