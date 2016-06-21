docker run --env=POLLING=true --name=jekyll --rm --label=jekyll --volume=c:/users/jflam/src/docs:/srv/jekyll -it -p 4000:4000 jekyll/builder:pages
