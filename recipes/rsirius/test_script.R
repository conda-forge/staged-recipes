library('Rsirius')
sdk <- SiriusSDK$new()
wrapper <- sdk$start()
Sys.sleep(20)
pspace <- wrapper$project_spaces_api$GetProjectSpaces()[[1]]$name
recipe_dir = toString(Sys.getenv('RECIPE_DIR'))
data <- paste0(recipe_dir,"/Kaempferol.ms")
wrapper$compounds_api$ImportCompounds(pspace, c(data))
config <- wrapper$computations_api$GetDefaultJobConfig()
Sys.sleep(5)
compoundId <- "1_Kaempferol_Kaempferol"
formulaId <- "C15H10O6_[M+H]+"
wrapper$computations_api$StartJob(pspace, config)
Sys.sleep(10)
wrapper$formula_results_api$GetFragTree(pspace, compoundId, formulaId, data_file="./test_fragtree.txt")
Sys.sleep(5)
sdk$shutdown()