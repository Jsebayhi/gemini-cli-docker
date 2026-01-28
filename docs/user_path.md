# The goal of this document is to document expected standard user path when using the project.

## multi account usage

launch gemini-toolbox with the google work account on project 1
interact with the gemini session on project 1

launch gemini-toolbox with the google personal account on project 2
interact with the gemini session on project 2

## local desktop

### gemini

launch gemini-toolbox
interact with the gemini session

### bash

launch gemini-toolbox with bash option
do stuff in the container

## local desktop from terminal in  VS code

launch gemini-toolbox
gemini connect to vs code with the companion extension
the user work with gemini and edit diff are opened in vscode directly

## local desktop from terminal for sandboxing (gemini or bash)

launch gemini-toolbox disabling docker for full sandboxing.

## debug container with bash (local or remote)

launch the gemini-toolbox in bash mode to inspect the content of the sandbox


## desktop <=> remote (gemini or bash)

launch the gemini cli activating the remote functionality.

works on the desktop from terminal
switch to the phone
switch back to the desktop
etc

## remote <=> desktop (gemini or bash)

open the hub
select the project
select the profile
open a cli session
interact with gemini from the phone
connect to the session from the desktop
interact with gemini from the desktop
switch to the phone
works on the desktop
etc

## remote gemini session

open the hub
select the project
select the profile
open a cli session
interact with gemini

## remote edit files

open the hub
select the project
select the profile
open a bash session
use vim to edit files

## sandbox bot

a script launch gemini-toolbox with a task for gemini. Gemini do the task then exit.