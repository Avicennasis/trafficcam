# trafficcam
Downloads a snapshot image from a traffic cam and emails it

The default is 10 images over 10 minutes. This can be modified, of course. 

"for i in {1..10}; " is your range (number of photos.) if you want more or less images, change the "10" to something else.

The "sleep 60" is a sleep timer for 60 seconds. If you want longer/shorter timeframes between emails, adjust this setting.

mpack is what sends the mail. This relies on ssmtp to be up and running.
