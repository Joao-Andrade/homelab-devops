# Management-node scripts

This folder contains scripts that may help configuring or cleaning up the homelab.

Scripts:

 - install_helm_timed.sh
   - Installs some application and outputs the time it took for the installation.
 - check_kub_nodes_periodically.sh
   - Checks the cpu and memory usage of the kubernetes nodes periodically.
 - testing-apps/
   - A subfolder that contains scripts to test the installation of some applications.
   - source-control/
     - Contains a script to test source control application (GitLab or Gitea). Creates ten repos, pulls them and push changes to each repo, including some big files. At the end cleans the repos from git server.
