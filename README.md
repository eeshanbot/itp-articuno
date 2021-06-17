# itp-articuno
Tools to streamline working with the WHOI Ice Tethered Profiler dataset

### Dependencies

- Python3 for downloading ITP files from the WHOI FTP server
- MATLAB for data exploration and analysis. I am working on translating the MATLAB infrastructure to Python (if you would like to contribute, hit me up).

### How to Use

1. Run Python/Bash scripts in `itp-file-downloader`. This will create a local copy of all the ITP data. The WHOI server stores this as `.zip` files, so if you want to update your local copy with only the new data, you cannot delete your local `.zip` files.
2. Run MATLAB scripts in `matlab-indexer`. This will create two `.mat` files that serve as searchable indexed libraries. You can easily load these `.mat` files into any script where you would like to use the ITP data, filter for the profiles of interest, and then only load those into memory.

I will continue to update this repository as I clean up and standardize my tools for working with ITP data.

### Notice

This is a tool- and science-driven extension of a summer '20 mentoring project via Duke University's "Keep Exploring" with Alexandra Rivera and Lara Breitkreutz. To see some great Google CoLab Python notebooks, please [go here](https://github.com/explore-ITP/explore-itp.github.io/tree/master/tutorials) to see their work.

All software provided as is, but feel free to submit issues + pull requests.
