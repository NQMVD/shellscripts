#!/usr/bin/env bash

# show commands
echo "
Available Commands:
  a, add <todo>           +project @context status:any/none due:tod/tom
  e, edit <id> <changes>
  c, complete <id>
  d, delete <id>
  p, prioritize <id>
  s, status <id> <status>
  ar, archive <id/c/gc>   (ar completed/d archieved)
  an, addnote <id> <note>
  en, editnote <id> <noteid> <changes>
  dn, deletenote <id> <noteid>
  uar, unarchive <id>
  uc, uncomplete <id>
  up, unprioritize <id>
"

# list
ultralist list

# by project
# by contect

# prompt
