This is a simple iOS app that utilizes a number of different iOS frameworks, in order to download a user list from Slack, and then populate a CollectionView, with consideration for caching images in memory and in the filesystem (/tmp).

Scrolling the list should be smooth and glitch free as the image download/processing is handled in on a background queue.   
