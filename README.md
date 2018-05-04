# Dockerfile for CPU version of Facebook Research wav2letter Application

The build and scripts necessary for a Dockerfile for [wav2letter](https://github.com/facebookresearch/wav2letter) from the Facebook Research group on Ubuntu.

The current build works successfully, though it takes about 2-3 hours to complete on a fast, C5.2xlarge instance on AWS. Each sentence of voice takes about 5 - 6 seconds to decode.

I'll likely create an AWS image of this next, as the Docker container this creates is about 70GB in size, too large for easily uploading and downloading on demand. Very likely it's best to start with the AWS Deep Learning AMI (Ubuntu) and have setup for GPU and CPU ready.