## Test environments
* local macOS R installation, R 4.3.2
* continuous integration via GH actions:
  * macOS latest release
  * windows latest release
  * ubuntu 20.04 latest release and devel
* [win-builder](https://win-builder.r-project.org/) (release, devel and old-release)
* [macbuilder](https://mac.r-project.org/macbuilder)
* [R-hub](https://builder.r-hub.io)
  - Windows Server 2022, R-devel, 64 bit
  - Ubuntu Linux 20.04.1 LTS, R-release, GCC
  - Fedora Linux, R-devel, clang, gfortran
  - Debian Linux, R-devel, GCC ASAN/UBSAN

## R CMD check results

0 errors | 0 warnings | 2 notes

    * This is a new release.
    * checking for GNU extensions in Makefiles ... NOTE
      GNU make is a SystemRequirements.
