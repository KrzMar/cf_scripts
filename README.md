# Cloud Foundry Scripts
[Loop over apps instances](https://github.com/KrzMar/cf_scripts/blob/main/loop_over_apps_instances.sh) script moves recursively through all applications (guids) instances (containers) and executes specified commands against them (via **SSH** without switching any ORGs and SPACEs). Each started app instance returns parsable json with the app's guid, it's instance index and your command output. Feed 'guids' and 'container_command' variables to run the script.

```bash
$ guids=$(cf curl /v3/apps | jq -r .resources[].guid) \
$ container_command="env | grep CF_INSTANCE_INTERNAL_IP | cut -d "=" -f 2" \
$ ./loop_over_apps_instances.sh
##########################################################################
## SSH access is limited by your current CF user (admin) role
##########################################################################
{"guid":"0b1638f7-a566-4317-b3e7-2592a12790f2","i":"0","output":"11.248.84.62"}
{"guid":"6064c81b-a841-4850-b55a-d98f8dad0c0d","i":"0","output":"11.255.154.14"}
{"guid":"6064c81b-a841-4850-b55a-d98f8dad0c0d","i":"1","output":"11.255.150.28"}
{"guid":"6064c81b-a841-4850-b55a-d98f8dad0c0d","i":"2","output":"11.255.76.6"}
{"guid":"6f79bc16-e707-40e1-996f-c190c529b877","i":"0","output":"11.250.127.8"}
{"guid":"91480187-8fc8-4824-a397-853e48f9300a","i":"0","output":"11.251.23.7"}
{"guid":"91480187-8fc8-4824-a397-853e48f9300a","i":"1","output":"11.255.151.32"}
{"guid":"91480187-8fc8-4824-a397-853e48f9300a","i":"2","output":"11.249.220.21"}
9f22ec91-6118-434a-9ff2-2c7c98608f98: stopped - can't ssh into app containers
{"guid":"30d28463-10de-40df-8a0c-d90ea2bc8d6f","i":"0","output":"11.251.215.13"}
{"guid":"203a970c-418f-4f9c-8e61-45df1ac9ee1c","i":"0","output":"11.249.119.22"}
```

\*it's not perfect and free of bugs - might require some adaptation  
\*\*tested on Ubuntu 18.04.5 LTS (Bionic Beaver), GNU bash, version 4.4.20, jq-1.5-1-a5b5cbe, cf version 6.51.0+2acd15650.2020-04-07
