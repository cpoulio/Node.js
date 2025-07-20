NodeJS.sh ReadMe!
=================

Nexus Tag:
----------

-   Node.JS-v20.18.1-linux-x64

How to Install:
---------------

-   Place the node-<*VERSION*>-linux-x64.tar.xz and the license file in the script's directory.

-   Run the script with *Install* using the `NodeJS.sh` script: `./NodeJS.sh --mode install`

-   Run the script with `setup.sh`, install is default and does not need an argument: `./setup.sh`

How to Uninstall:
-----------------

-   Run the script with *Uninstall* using the `NodeJS.sh` script: `./NodeJS.sh --mode uninstall`

-   Run the script with `setup.sh` for *Uninstall*: `MODE=uninstall ./setup.sh`
setup.sh → [validates args, calls]

    |

    ↓

main.sh → [parses --option, dispatches]

    |                   |                 |                 |                |                |

    |                   |                 |                 |                |                |

install.sh         uninstall.sh       verify.sh     uninstall_from_verify.sh   update.sh   update_after_uninstall_from_verify.sh

    |                   |                 |                 |                |                |

    |                   |                 |                 |                |                |

variables_functions.sh (sourced by all above)

update.sh / update_after_uninstall_from_verify.sh → uninstall_from_verify.sh → verify.sh
## Summary Table

| Script                   | Purpose/Role                                                  | Calls/Depends On                        |
|--------------------------|--------------------------------------------------------------|-----------------------------------------|
| `setup.sh`               | Entry point, sources variables/functions, calls `setup "$@"` | `variables_functions.sh`                |
| `variables_functions.sh` | Shared variables, utility functions, `setup` function        | -                                       |
| `main.sh`                | Sources all scripts, parses args, dispatches to correct function | All other scripts                   |
| `install.sh`             | Defines `install` function                                   | `variables_functions.sh` (for vars)     |
| `uninstall.sh`           | Defines `uninstall` function                                 | `variables_functions.sh` (for vars)     |
| `uninstall_all.sh`       | Defines `uninstall_all` function                             | `variables_functions.sh` (for vars)     |
| `upgrade.sh`             | Defines `upgrade` function                                   | `variables_functions.sh` (for vars)     |
| `verify.sh`              | Defines `verify` function                                    | `variables_functions.sh` (for vars)     |
| `uninstall_from_verify.sh` | Defines `uninstall_from_verify` function                   | `variables_functions.sh`, `verify.sh`   |

**Example Usage:**
```bash
./setup.sh --option install --email you@email.com


How to Update:
--------------

This will run the *install* and then *uninstall* functions.

-   Run the script with *Update* using the `NodeJS.sh` script: `./NodeJS.sh --mode update`

-   Run the script with `setup.sh` for *Update*: `MODE=update ./setup.sh`

### Install Mode:

1.  Install required YUM packages.
2.  Extract NodeJS from the tarball.
3.  Establish symbolic links for NodeJS binaries.
4.  Update the environment paths.
5.  Verify the NodeJS and npm installations.
6.  Send a completion email with the installation log.

### Uninstall Mode:

1.  Remove NodeJS binaries and directory.
2.  Remove symbolic links.
3.  Restore environment paths to their original state.
4.  Send a completion email with the uninstallation log.

Features
--------

-   Automates the installation and uninstallation of NodeJS.
-   Dynamically sets installation log file paths.
-   Handles prerequisite package installations using YUM.
-   Updates user environment for NodeJS setup.
-   Verifies installation by checking version of Node and npm.
-   Cleans up installation and restores system state on uninstallation.
-   Emails a log file upon completion of actions.

Prerequisites
-------------

-   YUM package manager is needed. Necessary development packages like `openssl-devel`, `bzip2-devel`, `libicu-devel`, `gcc-c++`, and `make` must be installed.
-   `mailx` is recommended but not required. This allows you to receive logs via email.

Variables
---------

-   `EMAIL_RECIPIENT`: Email address to receive log notifications.
-   `HOSTNAME`: Hostname of the system where the script is executed.
-   `INSTALLDIR`: Directory for NodeJS installation.
-   `NPM_VERSION`: Specific version of npm to be installed.
-   `VERSION`: Specifies the version of NodeJS to be installed.
-   `SOFTWARENAME`: Name of the software being installed (NodeJS).
-   `NODE_VERSION`: NodeJS version with the `v` prefix, used in constructing the filename and directory paths.
-   `LINUX_DISTRO`: Specifies the target Linux distribution architecture, typically set to `linux-x64`.
-   `NODEJSFILE`: Constructed filename for the NodeJS installation file.
-   `FILEPATH`: Path to the NodeJS binary files.
-   `YUM_PACKAGES`: List of packages to be installed via YUM.
-   `LOGDIR`: Directory for storing log files.
-   `DATE`: Current date and time, used in logs and filenames.

Check Variables
---------------

-   `echo "Deployment Directory=${deploy_dir}"`: Displays the deployment directory being used; defaults to `.` if not explicitly set.
-   `echo "${NODEJSFILE}"`: Shows the constructed filename for the NodeJS installation file.
-   `echo "${FILEPATH}"`: Prints the path where NodeJS binary files are located.
-   `echo "${NODE_VERSION}"`: Outputs the NodeJS version with the `v` prefix for clarity.
-   `echo "DATE=${DATE}"`: Displays the current date and time, useful for log timestamps.
-   `printf "DATE=%s\n" ${DATE}`: Another way to print the date, formatted for readability in logs.
-   `echo "${EMAIL}"`: Outputs the email address(es) used for notifications, verifying they are correctly set.

### Function Explanations

-   `log()`: Logs a message with a timestamp to the specified log file.
-   `send_email()`: Sends an email notification with the contents of the log file.
-   `install_YUM_packages()`: Installs necessary packages using YUM.
-   `extract_nodejs()`: Checks for the presence of the NodeJS tar file and extracts it to the installation directory.
-   `update_env_paths()`: Updates the user's environment paths to include the NodeJS binary path.
-   `temp_profile()`: Temporarily adds the NodeJS binary path to the current session's `PATH`.
-   `backup_and_remove_old_paths()`: Backs up profile files and removes outdated NodeJS paths.
-   `install()`: Combines installation steps, including package installation, NodeJS extraction, path updates, symbolic link creation, and version verification. Sends a summary email upon completion.
-   `uninstall()`: Removes NodeJS files, symbolic links, and profile entries. Sends an email notification after uninstallation.
-   `update()`: Uninstalls any existing NodeJS version and reinstalls the latest version. An email summary is sent upon completion.

Execution Logic:
================

Command-Line Arguments Check:
-----------------------------

### Explanations

```
   for ARG in "$@"
   do
     case $ARG in
       install|uninstall|update)
         echo "Arg: $ARG"
         MODE=$ARG
         echo "MODE=${MODE}"
       ;;
       *)
         # Handle other arguments or ignore
       ;;
     esac
   done

```

Main Execution Logic
====================

### Explanations

```
case ${MODE} in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    update)
        update
        ;;
    *)
        echo "Invalid mode. Usage: MODE={install|uninstall|update} $0 or $0 {install|uninstall|update}"
        exit 1
        ;;
esac

```

Additional Notes
----------------

-   The script assumes mailx is configured for sending emails.
-   Error handling ensures the script exits if any significant failure occurs.
-   System modifications such as environment path updates and symbolic links are critical for correct NodeJS operation.
-   Correct file permissions are required for successful execution.
-   The `setup.sh` script serves as the entry point, ensuring all environment variables are set correctly before invoking `NodeJS.sh`.
-   The script is designed for system administrators managing NodeJS deployments on Unix-based environments.
