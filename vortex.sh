#!/bin/bash
# Fork of cs2110docker.sh

release="stable"
imageBaseName="vtx"
imageName="${imageBaseName}:${release}"

define() { IFS=$'\n' read -r -d '' "${1}" || true; }

description="Run the vortex Docker container"

usage_text=""
define usage_text <<'EOF'
USAGE:
    ./vortex.sh [start|stop|-h|--help]

OPTIONS:
    start
            Start a new vortex container, and enter shell. Exiting the container stops and removes it automatically.
    -h, --help
            Show this help text.
EOF

print_help() {
  # print to stderr
  >&2 echo -e "$description\n\n$usage_text"
}

print_usage() {
  >&2 echo "$usage_text"
}

action=""
if [ $# -eq 0 ]; then
  # no args, default to start
  action="start"
elif [ $# -eq 1 ]; then
  case "$1" in
    start)
      action="start"
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      >&2 echo "Error: unrecognized argument: $1"
      >&2 echo ""
      print_usage
      exit 1
      ;;
  esac
elif [ $# -gt 1 ]; then
  >&2 echo "Error: too many arguments"
  >&2 echo ""
  print_usage
  exit 1
fi

# Check if Docker is installed
if ! docker -v >/dev/null; then
  >&2 echo "ERROR: Docker not found. Please install Docker before running this script."
  exit 1
fi

# Check if Docker is active
if ! docker container ls >/dev/null; then
  >&2 echo "ERROR: Docker is not currently running. Please start Docker before running this script."
  exit 1
fi

# Check for existing container (either running or stopped)
existing=0
existingContainers=($(docker ps -a | grep "$imageBaseName" | awk '{print $1}'))
if [ "${#existingContainers[@]}" -ne 0 ]; then
  existing=1
  msg="Found existing vortex container: "
  container="${existingContainers[@]}"
  msg1="$msg$container"
  echo $msg1
else
  echo "No Existing vortex Containers Found"
fi

# Get current working directory
if command -v docker-machine &> /dev/null; then
  # We're on legacy Docker Toolbox
  # pwd -W doesn't work with Docker Toolbox
  # Extra '/' fixes some mounting issues
  currDir="/$(pwd)"
else
  # pwd -W should correct path incompatibilites on Windows for Docker Desktop users
  currDir="/$(pwd -W 2>/dev/null || pwd)"
fi

# windows mode?
if [ "$action" = "start" ]; then
  if command -v winpty &> /dev/null; then
    # Run with winpty when available
    winpty docker build --platform=linux/amd64 -t vortex .
    winpty docker run --rm -v "$currDir":/root/vortex/ -it --name vtx --privileged=true --platform=linux/amd64 vortex
  else
    docker build --platform=linux/amd64 -t vortex .
    docker run --rm -v "$currDir":/root/vortex/ -it --name vtx --privileged=true --platform=linux/amd64 vortex
  fi
  exit 0
fi
