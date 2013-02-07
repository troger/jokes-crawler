# jokes-crawler

## Overview

This scripts crawls the given URL from [jokes](http://www.jokes.com/) to extract messages and post them to the specified SosMessage API URL.

Sample usage:

    ./jokes-crawler.rb -u http://www.jokes.com/funny-men-women -s http://localhost:3000 -c 4f6a4f80744e34609b3c8127

The crawler will fetch itself all the joke links for the category

Full options:

    Usage: jokes-crawler.rb [options]
    -c, --category-id CATEGORY_ID    The category id where to post the jokes
    -s, --sosmessage-url URL         The SosMessage API url
    -u, --messages-url URL           The jokes category url
    -f, --max-messages MAX           MAX messages to fetch
    -m, --max-characters MAX         MAX characters of the joke
    -n, --dry-run                    Don't actually post the messages, only display them
    -h, --help                       Display this screen
