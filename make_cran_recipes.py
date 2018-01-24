import skeleton_helper as sh
import subprocess as sp
def main():
    with open('packages_to_process.txt', 'r') as file, open("failed_packages.txt","w") as failed_packages, open("build_succes_packages.txt", "w") as succes_packages:
        for line in file.readlines():
            try:
                sh.write_recipe(line[2:-1], 'recipes')
                returncode = sp.call(['conda build recipes/' + line], shell=True)
                if(returncode == 0):
                    handleGithub(line)
                    succes_packages.write(line)
                else:
                    failed_packages.write(line)
            except FileNotFoundError as e:
                print("Could not find {} on cran".format(line))

def handleGithub(package):
    sp.call('git checkout master', shell=True)
    sp.call('git checkout -b ' + package, shell=True)
    sp.call('git add recipes/' + package, shell=True)
    sp.call('git commit -m \"added ' + package + '\"', shell=True)
    sp.call('git push origin ' + package, shell=True)


if __name__=="__main__":
    main()
