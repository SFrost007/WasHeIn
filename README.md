Was He In..?
============

This is a simple (JQuery-Mobile based) iPhone application for cross referencing movies using IMDB. Enter two movies or TV shows, and the app will return a list of actors who appear in both.

Due to IMDB's lack of a published API, this works as a mash-up of two approaches:

* Autocomplete is achieved using the same method used on IMDB's own site
* Actor listing are retrieved by scraping the movie cast page

While there are a plethora of third-party APIs/wrappers around such data, unfortunately these all only return the movie summary page rather than the full cast, rendering them less useful for this particular case.

The native code is a thin wrapper around the webview control, adding options to open any actor's details page in a browser of the user's choice.

The web files will work on any browser capable of running JQuery, however due to the screen-scraping required, this cannot be hosted on a web server and accessed directly via a browser due to cross-origin security policies.
