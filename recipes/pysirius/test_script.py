from PySirius import SiriusSDK
import os
import time


sdk = SiriusSDK.start()
time.sleep(10)
pspace = sdk.get_ProjectSpacesApi().get_project_spaces()[0].name
path = os.getenv('RECIPE_DIR') + "/Kaempferol.ms"
path = os.path.abspath(path)
sdk.get_CompoundsApi().import_compounds([path], pspace)
time.sleep(10)
config = sdk.get_ComputationsApi().get_default_job_config()
formulaId = "C15H10O6_[M+H]+"
fallback_adducts = ["[M+H]+","[M]+,[M+K]+","[M+Na]+","[M+H-H2O]+","[M+Na2-H]+","[M+2K-H]+","[M+NH4]+","[M+H3O]+","[M+MeOH+H]+"]
detectable_adducts = ["[M+H]+","[M]+,[M+K]+","[M+Na]+","[M+H-H2O]+","[M+Na2-H]+","[M+2K-H]+","[M+NH4]+","[M+H3O]+","[M+MeOH+H]+"]
formula_id_paras = sdk.get_models().Sirius(True)
compoundId = sdk.get_CompoundsApi().get_compounds(pspace)[0].id
jobSub = sdk.get_models().JobSubmission([sdk.get_CompoundsApi().get_compounds(pspace)[0].id], fallback_adducts, None, detectable_adducts, True, formula_id_paras)
time.sleep(10)
job = sdk.get_ComputationsApi().start_job(jobSub, pspace)
time.sleep(10)
tree = sdk.get_FormulaResultsApi().get_frag_tree(pspace, compoundId, formulaId)
SiriusSDK.shutdown()

with open('test_fragtree.txt', 'w') as f:
    f.write(str(tree))
