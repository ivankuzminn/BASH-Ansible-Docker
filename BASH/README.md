-BASH
BASH script that deploys the following stack on a Linux distribution: Apache2; mysql; php; Wordpress; Nginx (as a server that “proxyes” requests to the Apache service).
Web server configuration files are taken in the form of ready-made templates.
Upon completion, the script sends a notification with the execution result via the TG-bot.
The script is implemented so that if the connection is interrupted or the execution is restarted, the script will continue and complete the task.
Added use of GIT repository for web server configuration files.