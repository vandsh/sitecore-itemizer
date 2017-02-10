### What is it? ###
A couple of powershell scripts and a gulpfile.

### What does it do? ###
It parses .item files, grabs fields (blob in this case, but can be extended), and generates tangible content items from those fields.

Example: `/sitecore/assets/css_asset.item -> /sitecore/assets/css_asset.css`

It also does the inverse, when a change is made to the content item, it updates the associated .item file (right now it creates another version of the field in the item).

Example: `/sitecore/assets/css_asset.css-> /sitecore/assets/css_asset.item`

It only will update the associated files if there has been a change detected and the field content does not match (so you won't get stuck in an infinite update loop)

### What do I need it for? ###
The first use case I thought for this was SXA, or the local development of themes for SXA, to help aid the development workflow around assets that will exist in Sitecore itself (css/js etc).  I also figure it could be used outside of that, anywhere where you have assets stored in the file system that you will eventually want in Sitecore (media library for example).

### How do I use it ###
Should be as easy as:

1. Clone, download, whatever, just get these files into your project

1. Update the `paths.themeSrc` and `paths.itemSrc` variables in the `gulpfile.js`

1. `npm install` to get the needed dependencies (yes this is assuming you have node installed on your local machine)

1. `gulp default` to start the gulp watchers (yellow is a change to an asset, blue is a change to an item)