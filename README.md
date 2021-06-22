# Crawling@Home

> Help us build a billion-scale image-caption dataset by filtering Common Crawl with OpenAI CLIP

## Concept
This scraping task comes with specific characteristics: link lists might be old and images might not be online anymore, even entire domains might be missing. Also there are seldom multiple links pointing to the same domain, so the DNS queries are many and often. Finally after the actual scraping there is a computational intensive task to calculate similarities between images themselves and their captions.

On a normal CPU machine, scraping and filtering take almost the same time. On a GPU though filtering is much faster, in order of 60x faster than on single CPU.

Hence this concept for crawling@home where a cental GPU machine can drive a swarm of cloud workers then perform computing intensive task on GPU.

At this time the script is tested on a single GPU driving 20 workers. At full load we estimate getting about 6M pairs per 24 hours for the cost of using the local GPU and 6 Euro in Hetzner could computing.

## Prerequisites
1. Ubuntu box with 8GB+ Nvidia GPU
2. Nvidia driver installed
3. Cuda toolkit 11.0 and corresponding cudnn installed
4. check driver installation with `nvidia-smi` command
5. your user is able to run `sudo` commands
6. install `python3-pip` and `git` packages
## Distributed infrastructure setup and run
1. Make an account at Hetzner Cloud (https://www.hetzner.com/) and issue an API token
2. run `git clone https://github.com/rvencu/crawlingathome-worker --branch client-server`, to download crawlingathome-worker client-server script
3. run `cd crawlingathome-worker`, to enter the newly created directory
4. create the `.env` file and paste your HCLOUD API key in it. optionally, if you have more than one account, paste all API keys each on a separate line
5. run `source conda-setup.sh` to setup the environment if you use anaconda. otherwise use `source pip-setup.sh`. the script will ask for a nickame to be used on leaderboard as well as for the sudo password
6. run `python3 gpu.py N`, to start Distributed Crawling with Central GPU Processing with 10 remote droplets! You can interrupt the script with Ctrl-C and infrastructure will be automatically shut down after all logs from the droplets would have been collected on GPU node. Change N with any number you like provided it is withing your cloud account limits.
7. tear down infrastructure at any time with `python3 infrastructure.py down` in order to shutdown things (and save cash). this will shut down all cloud servers that belong to all API keys saved in the `.env` file

The GPU console will cycle status messages from all droplets. If you wish to SSH into any droplet you can use this command: `ssh -oStrictHostKeyChecking=no -oIdentitiesOnly=yes -i~/.ssh/id_cah crawl@<<droplet_ip>>`. The crawling script is ran as a service, check logs with `tail -f crawl.log`. Access service status or commands with `sudo systemctl stop|restart|start crawl`

If you are asked for any droplet root password at any time, it means you need to rerun `git pull` and `source conda-setup.sh` to refresh the files and regenerate the ssh keys pair.

## TODO
- [x] Save image embedding 
- [x] Convert images to tfrecords
- [x] Upload to google drive
- [x] Prevent corrupt image to be processed
- [x] Shard of chunk (it needs to read all WAT file which will be bad for low ram server)
- [x] Crawling@Home integration
- [x] Verify output
- [X] Automate infrastructure from main script
- [X] Replace Pillow with Pillow-SIMD
- [x] Automate nickname as environment variable
- [x] Detect stalled nodes and restart jobs
- [x] Manage GPU process crashes
- [x] Spread droplets to all locations to avoid cpu/network competition on same hardware
- [ ] Add continuous deployment pipline so workers get updates without shutting down
- [x] Add option to use multiple HCLOUD API keys (to aggregate multiple accounts into the same swarm)