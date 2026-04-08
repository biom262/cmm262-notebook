# BNFO262 notebook environments
This repository houses the source code for the compute environments used in BNFO 262 at UC San Diego. Each directory in this repository corresponds with a different Docker image. There is one image for each weekly module of the course.

GitHub actions automatically build and push updates to each environment for any commits made to the `master` branch or to a PR that will be merged into `master`. Images from PRs are tagged by their PR number.

## Our docker images
Our docker images are pushed to GitHub's container registry, not Docker's. You can find a list of our docker images in [the "Packages" section](https://github.com/orgs/biom262/packages?repo_name=cmm262-notebook) in the right sidebar of this repository.

The following container registry URLs can be provided to the DataHub team at the beginning of every academic quarter:
> ghcr.io/biom262/chipseq:master
>
> ghcr.io/biom262/gwas:master
> 
> ghcr.io/biom262/imgproc:master
>
> ghcr.io/biom262/networks:master
>
> ghcr.io/biom262/popgen:master
> 
> ghcr.io/biom262/programming-R:master
>
> ghcr.io/biom262/rna-seq:master
>
> ghcr.io/biom262/scrna-seq:master
> 
> ghcr.io/biom262/spatial-tx:master
>
> ghcr.io/biom262/stats:master
>
> ghcr.io/biom262/variant_calling:master

## Modifying an environment

1. First, click here to create a [GitHub codespace](https://github.com/features/codespaces):

    https://github.com/codespaces/new/biom262/cmm262-notebook?skip_quickstart=true&machine=standardLinux32gb

    A GitHub codespace is a pre-configured VSCode development environment that will have all of the necessary tools pre-installed. Codespaces are free with the [student developer pack](https://education.github.com/pack).

   Instead of a codespace, you can also just clone the repository locally. In that case, you should also make sure to install conda and `conda-lock`.
    ```
    conda create -yn lock 'conda-forge::conda-lock'
    ```
2. Create a new branch off of the `master` branch. Give it an informative name.
3. Add the new software to the conda environment used by that module. Make sure to follow best practices (see the section below)!

   Note: **Never** use one conda `environment.yml` file for more than one module. Each module should have its own `.yml` file. Mixing modules into the same environment will make it difficult for future TAs to maintain the environment, since they won't be able to tell which packages to add or remove as the notebooks change.
5. Check that the conda environment can still be solved by doing a dry-run
    ```
    conda env create --dry-run --file environment.yml
    ```
6. Make sure to update the `conda-linux-64.lock` file

   If you added or modified a package, you should update just that package:
    ```
    conda activate lock
    conda-lock --kind explicit --platform linux-64 --file environment.yml --update PACKAGENAME
    ```
    Otherwise, you can just regenerate the entire `.lock` file from scratch:
    ```
    conda activate lock
    conda-lock --kind explicit --platform linux-64 --file environment.yml
    ```
8. Commit and push your changes
9. Once you're ready, create a pull request to merge it back into the `master` branch
10. Wait at most 30 minutes for the images to be built and for the checks to pass
11. You should see a green check-mark if all of the checks pass. If not, click on the red X and then "Details" to view the error message. Add additional commit(s) to fix the issue.
12. Test your changes (see section below) and add any commits as needed
13. Once all checks and tests pass, merge your pull request!

## Testing a new environment
Once you create a pull request within our notebook repository, GitHub actions will automatically build an updated set of Docker images. The images will be tagged by the number assigned to your pull request.
1. (If off-campus) connect to the UCSD VPN. Then log into DataHub via `ssh` from your terminal. You may need to enter your UCSD username/password.
    ```
    ssh username@dsmlp-login.ucsd.edu
    ```
2. Run your container on DataHub
    ```
    launch-scipy-ml.sh -W BNFO262_WIXX_A00 -P Always -i ghcr.io/biom262/MODULENAME:pr-#
    ```
    Within the above command, you should replace the following:
    - `XX` should be replaced with the last two digits of the current year (ex: `24` for 2024)
    - `MODULENAME` should be replaced with the module name (ex: `chipseq`)
    - `#` should be replaced with the ID number of the pull request (ex: `11` for [this pull request](https://github.com/biom262/cmm262-notebook/pull/11))
3. Executing that command will generate a URL to a DataHub environment that uses your updated changes. Open the URL in your browser, and use that notebook environment to test if your changes work as expected. You should rerun your notebooks one more time here -- there's a possibility that they don't work here, even if they worked earlier!

    If the URL isn’t working, make sure you connect to the UCSD VPN.

    **Note**: If DataHub gives you "Error: ImagePullBackOff", then it probably means that your container image has yet to be pushed to the image repository. You can check the list of available images that have been pushed to the image repository [here](https://github.com/orgs/biom262/packages?repo_name=cmm262-notebook). If the `pr-#` tag does not appear there, then you will probably need to wait a bit and check back later.

## Best practices for conda environments
![reproducible_conda_envs](https://github.com/aryarm/demo-docker-action/assets/23412689/791efa84-53dd-4fca-8ea8-8c7029c0528b)
1. **[Write your environment file manually](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#create-env-file-manually)**. Don't create an environment and then export it to a `.yml` file using `conda env export`. This will inevitably create `.yml` files that cannot be easily updated in future years. Also, the `.yml` file will be unlikely to work with other environments besides your own (or other _base_ Docker images besides the one from which you exported it) because of the inclusion of system-level packages.

   You can try to avoid system-level packages by providing the `--from-history` or `--no-builds` flags but the resulting file will likely have dependency conflicts. It will also need lots of manual editing to make it follow the rest of the best practices. There is simply no replacement to a manually written file.
2. Always specify conda-forge before bioconda in the channels list if both of them are needed. Note that conda-forge is needed whenever bioconda is needed, but the opposite is not true.
3. You should only use packages from community-driven, open-source channels like `conda-forge` and `bioconda`. Other channels (like `anaconda`, `r`, and `defaults`) have been known to eventually purge old packages, breaking existing `.yml` files.
4. You should also specify `nodefaults` as a channel in the channels list, since the defaults channel conflicts with conda-forge.
When possible, you should specify exact package versions and channels to reduce the amount of time it takes for conda to find the correct versions and channels to use (aka "solve the environment"). This also makes the `.yml` file much more reproducible and less likely to break in the future.

   Here's an example where we specify the channel name (_conda-forge_), the package name (_r-base_), and the package version (_3.6.3_):
    ```
    dependencies:
      - conda-forge::r-base==3.6.3
    ```
    To pin to exact package versions, use a double equals `==` instead of a single equals `=` sign. If you aren't sure which versions to specify, you can do a dry run without versions and then choose whichever versions are chosen by the dry run.
5. If a package can be installed via conda, do not specify it as a pip dependency in your environment file. Avoid pip dependencies if possible.
6. Do not include dependencies of any packages already listed in your environment file unless you import or use those dependencies in your own code.

    For example, if you use `scanpy` and it imports `pytables`, you shouldn't add `pytables` to your `.yml` file unless you directly import and use `pytables` in your code. This rule helps to ensure `.yml` files can be easily updated in future years.
7. When checking whether your environment file will solve, make sure the [--strict-channel-priority](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html#strict-channel-priority) setting is turned on. See [here](https://conda-forge.org/docs/user/tipsandtricks.html#how-to-fix-it) for more info.
8. If you are creating an environment that should be used from an R notebook, you must also specify the [r-irkernel](https://anaconda.org/conda-forge/r-irkernel) package as a dependency. This allows the environment to be detected by DataHub's [nb_conda_kernels](https://github.com/anaconda/nb_conda_kernels).
    ```
    dependencies:
      - conda-forge::r-irkernel==1.3.1
    ```
    Otherwise, if you are creating an environment that should be used from a Python notebook, specify the [ipykernel](https://anaconda.org/conda-forge/ipykernel) package. In either case, be sure to specify a version. I would recommend using [the most recent one](https://anaconda.org/conda-forge/ipykernel) unless the other packages in your environment are too old.
    ```
    dependencies:
      - conda-forge::ipykernel==6.20.1
    ```

## References
- The steps to test images were taken from DataHub's documentation: https://github.com/ucsd-ets/datahub-example-notebook
- This repository is modeled after https://github.com/aryarm/demo-docker-action. Please post issues and questions on that repository.
