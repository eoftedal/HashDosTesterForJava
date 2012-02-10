This is a small script to test _your_ java app for resilliance against HashDos

## What is hashdos
See http://events.ccc.de/congress/2011/Fahrplan/events/4680.en.html
It's an attack abusing the fact that it's easy to find java strings that have the same hashcode, and thus flood the parsing of an HTTP POST request with loads of paramaters having the same hash. 
Because java apps often build a hashtable/hashmap of parameters on the server side, and a hashtable/hashmaps often resorts to a linked list for values having the same hash, the performance takes
a hit for these kinds of requests. 

## How do I use it?
`ruby HashDosTester.rb http://the.url.of.my.site/ number_of_parameters`
Start with a small number (100) and increase to 500, 1000, 2000, 5000. 
Check if the time difference between the bening and attack request is suddenly deviating (by several thousand percent).
If the attack is much slower than the bening your application is most likely vulnerable.

