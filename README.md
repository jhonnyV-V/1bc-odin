this repo is just a bad attempt at the 1 billion row challenge
I was using my own hardware specs as a target and not the original challenge hardware

- a painfully slow hard drive (WDC WD10PURZ-85U) as far as I was able to find it has a 151MB/sec read speed
- 12gen intel i5
- and 16gb ddr4 memory

the measurement file with 1 billion rows using the create_measurement2.sh has a size around 1300MB (13147MB in my case) or 12.7GB
if we trust the information I found about my hard drive read spead it would take around 87 seconds to read the whole file
not event close to the 1brc records, so if we expect some overhead in a cold read probably it is possible to procces the file
in the range of 90 - 110 seconds and most of the time should be just reading from the file
but cache reads seems to be really fast, after testing with hdparm it seems to be possible to read 1500MB/sec
and after some attempts with 0 concurrency it is possible to procces in under 70 seconds when building with -o:speed
my target is to get the cold reads as close as possible to the 100 seconds mark
