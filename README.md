# BNFO262 notebook environments

## Modifying an environment

1. First, clone this repository
2. Create a new branch off of the `master` branch. Give it an informative name.
3. Add the new software to the conda environment used by that module. Make sure to follow best practices (see the section below)!
   Note: **Never** use more one conda environment.yml file for more than one module. Each module should have its own .yml file. Mixing modules into the same environment will make it difficult for future TAs to maintain the environment, since they won't be able to tell which packages to add or remove as the code in the notebooks changes.
4. Check that the conda environment can still be solved
    ```
    mamba env create --dry-run --file spatial-tx.yml
    ```
5. Commit and push your changes
6. Once you're ready, create a pull request to merge it back into the `master` branch
7. Wait at most 40 minutes for the image to be built and for the checks to pass
8. You should see a green check-mark if all of the checks pass. If not, click on the red X and then "Details'' to view the error message. Add additional commit(s) to fix the issue.
9. Test your changes (see section below) and add any commits as needed
10. Once all checks and tests pass, merge your pull request!

## Testing a new environment
**Note**: This section is now outdated. There used to be a way to test actions before they are live. But, at the moment, any successful changes to the environments (even on an unmerged pull request) will be immediately live on DataHub! This can be dangerous. Use with caution.

After creating a pull request for changes to our Dockerfile or a conda environment within our notebook repository, Github actions will automatically build an updated Docker image. The image will be tagged by the number assigned to your pull request.
1. (If off-campus) connect to the UCSD VPN. Then log into DataHub via ssh from your terminal.
    ```
    ssh username@dsmlp-login.ucsd.edu
    ```
2. Run your container on DataHub
    ```
    launch-scipy-ml.sh -W BNFO262_WIXX_A00 -P Always -i ghcr.io/biom262/cmm262-notebook:pr-#
    ```
    You should replace `#` with the module name and `XX` with the last two digits of the current year. For example, `XX` would be 24 for 2024. For example, the number for [this pull request](https://github.com/biom262/cmm262-notebook/pull/11) is 11.
3. Executing that command will generate a URL to a DataHub environment that uses your updated changes. Open the URL in your browser, and use that notebook environment to test if your changes work as expected. You should rerun your notebooks one more time here -- there's a possibility that they don't work here, even if they worked earlier!

    If the URL isn’t working, make sure you connect to the UCSD VPN.

    **Note**: If DataHub gives you "Error: ImagePullBackOff", then it probably means that your container image has yet to be pushed to the image repository. You can check the list of available images that have been pushed to the image repository [here](https://github.com/biom262/cmm262-notebook/pkgs/container/cmm262-notebook). If the tag does not appear there, then you will probably need to wait a bit and check back later.

## Best practices for conda environments
1. Always specify conda-forge before bioconda in the channels list if both of them are needed. (Note that conda-forge is needed whenever bioconda is needed, but the opposite is not true.)
2. You should avoid using packages from anywhere else but the conda-forge and bioconda channels. Other channels (like anaconda and r) have been known to eventually purge old packages.
3. You should also specify `nodefaults` as a channel in the channels list, since the defaults channel conflicts with conda-forge.
When possible, you should specify exact package versions and channels to reduce the amount of time it takes for conda to find the correct versions and channels to use (aka "solve the environment"). This also makes the yml file much more reproducible and less likely to break in the future. Here's an example where we specify the channel name (_conda-forge_), the package name (_r-base_), and the package version (_3.6.3_):
    ```
    dependencies:
    - conda-forge::r-base==3.6.3
    ```
    To pin to exact package versions use a double equals == instead of a single equals = sign.
4. If a package can be installed via conda, do not specify it as a pip dependency in your environment file. Avoid pip dependencies if possible.
5. **Write your environment file manually**. Don't create an environment and then export it to a yaml file. This will inevitably create yaml files that cannot be easily updated in future years. Also, the yaml file will be unlikely to work with other _base_ Docker images besides the one from which you exported it.
6. Do not include dependencies of any packages already listed in your environment file unless you import or use those dependencies in your own code.
    For example, if you use `scanpy` and it imports `pytables`, you shouldn't add `pytables` to your conda environment file unless you directly import and use `pytables` in your code. This makes it easier to maintain the environment file.
7. When checking whether your environment file will solve, make sure the [--strict-channel-priority](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html#strict-channel-priority) setting is turned on. (See [here](https://conda-forge.org/docs/user/tipsandtricks.html#how-to-fix-it) for more info.)
8. If you are creating an environment that should be used from an R notebook, specify the [r-irkernel](https://anaconda.org/conda-forge/r-irkernel) package as a dependency.
    ```
    dependencies:
    - conda-forge::r-irkernel==1.3.1
    ```
    Otherwise, if you are creating an environment that should be used from a Python notebook, specify the [ipykernel](https://anaconda.org/conda-forge/ipykernel) package.
    ```
    dependencies:
    - conda-forge::ipykernel==6.20.1
    ```
