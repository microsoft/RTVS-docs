# Note that in Docker for Windows, you must use the Docker Settings app (in the
# tray) to tell Docker you want to share your C drive, and you will be prompted
# to enter credentials needed to connect to your C drive.

docker run --env=POLLING=true --name=jekyll --rm --label=jekyll --volume=$(get-location):/srv/jekyll -it -p 4000:4000 jekyll/builder:pages
