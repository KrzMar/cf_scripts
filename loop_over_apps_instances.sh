#!/bin/bash
echo "##########################################################################" 1>&2
echo "## SSH access is limited by your current CF user ($(cf t | grep user | awk '{print $NF}')) role" 1>&2
echo "##########################################################################" 1>&2

#command to be done inside the container
container_command="env | grep CF_INSTANCE_INTERNAL_IP | cut -d "=" -f 2"
#container_command="cat ~/app/logs/staging_task.log | grep 'Java version selected'"

guids=""

ssh_link=$(cf curl / | jq -r .links.app_ssh.href)
ssh_host=$(echo $ssh_link | cut -d ':' -f 1)
ssh_port=$(echo $ssh_link | cut -d ':' -f 2)

function ssh_container {

#a workaround for failing execution if password starts with dash
while [[ "$password" =~ ^-.* || -z $password ]]; do
  password=$(cf ssh-code 2> /dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Unable to obtain ssh-code"
    exit 1
  fi
done

expect -c "
  spawn ssh -p $ssh_port cf:${guid}/${i}@$ssh_host $container_command
  expect {
    "*password:" { send "${password}"\r\n;exp_continue }
    eof { exit }
  }
  exit
  "
}

for guid in $guids; do
  app_state=$(cf curl /v3/apps/${guid} | jq -r .state)
  if [[ $app_state == "STOPPED" ]]; then
    echo "$guid: stopped - can't ssh into app containers" 1>&2
    continue
  fi
  stats=$(cf curl /v3/processes/${guid}/stats)
  no_of_instances=$(echo "$stats" | jq -r '.resources |length')
  for (( i = 0; i < $no_of_instances; i++ )); do
          remote_ssh_command_output=$(ssh_container $guid $i | grep -v 's password:' | grep -v 'spawn')
          remote_ssh_command_output="${remote_ssh_command_output%%[[:cntrl:]]}"

          output=$(echo "$remote_ssh_command_output") ### <- feel free to parse your output here as well
          JSON_STRING=$( jq -n \
                  --arg guid "$guid" \
                  --arg i "$i" \
                  --arg output "$output" \
                  '{guid: $guid, i: $i, output: $output}' )
          echo "$JSON_STRING" | jq -c .
  done
done
