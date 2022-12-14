# itp-articuno
Tools to streamline working with the WHOI Ice Tethered Profiler dataset

### Dependencies

- Bash (really just wget)
- MATLAB for data indexing

### How to Use

1. Run Bash scripts in `itp-file-downloader`. This will create a local copy of all the ITP data in `itp-data` while only downloading files that have changed since the last download. It is recommended that you do not delete your zip files if you want to consistently update your local ITP database.
2. Run `itp_unzip.sh` in `itp-file-downloader`. This automatically unzips new downloads and takes care of the `39_1` file name.
3. Run MATLAB scripts in `matlab-indexer`: `index_itp_data` and `index_itp_rawlocs`. These will create two `.mat` files that serve as searchable indexed libraries. You can easily load these `.mat` files into any script where you would like to use the ITP data, filter for the profiles of interest, and then only load those into memory.

I will continue to update this repository as I scale up and standardize my tools for working with ITP data.

### DEMO

1. Please see `matlab-reader/demo-ts-diagram` for an example of how to use the indexed dataset and helper functions

### Notice

This is a tool- and science-driven extension of a summer '20 mentoring project via Duke University's "Keep Exploring" with Alexandra Rivera and Lara Breitkreutz. To see some great Google CoLab Python notebooks, please [go here](https://github.com/explore-ITP/explore-itp.github.io/tree/master/tutorials) to see their work.

All software provided as is, but feel free to submit issues + pull requests.
