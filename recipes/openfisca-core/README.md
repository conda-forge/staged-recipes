# Anaconda publish

Hello, for Anaconda, I better understand the system, there is in fact three possibilities :
1- The easiest is to add a meta.yaml in of-core and push to an openfisca account to an openfisca "channel" (~ repository) on Anaconda.
2- An harder one is to push to "Conda-Forge" wich is an official channel with 16 674 package.
3- The hardest/impossible is to add openfisca to the main repo "anaconda", where there is 2 587 packages like pandas.
The advantage of the second option is a better CI (made by Anaconda team on Windows, Linux and MacOS) and an easiest way to install for our user. The first option require our users to add our own channel.
So I'm going with the second option. That require to fork an Anaconda repo in the OpenFisca project to configure the meta.yaml required by conda. This fork is then used to make a PR to Anaconda.
