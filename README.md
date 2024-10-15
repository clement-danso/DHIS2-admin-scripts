# DHIS2 Scripts

This repository contains a collection of scripts designed to enhance the functionality and usability of the DHIS2 platform. These scripts can be used for data manipulation, automation of tasks, and integration with other systems.

These scripts work for the DHIS2 installation described in the [DHIS2 Tools NG repository](https://github.com/bobjolliffe/dhis2-tools-ng).


## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Scripts Overview](#scripts-overview)
- [Contributing](#contributing)


## Installation

To use the scripts in this repository, clone the repository to your local machine:


git clone https://github.com/yourusername/dhis2-scripts.git
cd dhis2-scripts



## Usage

Each script has its own usage instructions. Please refer to the comments at the top of each script file for specific details on how to run them.

## Scripts Overview

- **db_backup.sh**: Creates a backup of the database and uploads it to S3 storage.
- **reboot_server.sh**: Reboots the server with a 5-second delay.
- **restore.sh**: Restores a database from a gzip-compressed dump file.
- **renewssl.sh**: Renews the SSL certificate for a specified domain.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss changes.

