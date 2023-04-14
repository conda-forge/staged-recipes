options(error = traceback)

library('Rsirius')

sdk <- SiriusSDK$new()
wrapper <- sdk$start()

wait_for_job <- function(pid, job) {
  while (!(wrapper$computations_api$GetJob(pid, job$id)$progress$state == "DONE")) {
    Sys.sleep(1)
  }
}

pspace <- wrapper$project_spaces_api$GetProjectSpaces()[[1]]$name
data <- file.path(Sys.getenv('RECIPE_DIR'),"Kaempferol.ms")
wrapper$compounds_api$ImportCompounds(pspace, c(data))
config <- wrapper$computations_api$GetDefaultJobConfig()
compoundId <- "1_Kaempferol_Kaempferol"
formulaId <- "C15H10O6_[M+H]+"
compute_job <- wrapper$computations_api$StartJob(pspace, config)
wait_for_job(pspace, compute_job)
wrapper$formula_results_api$GetFragTree(pspace, compoundId, formulaId, data_file=file.path(".","test_fragtree.txt"))
sdk$shutdown()
