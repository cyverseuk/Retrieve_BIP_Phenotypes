# Docker container for retrieveing Phenotypic data from the Brassica Information Portal.
# It uses the BIP-API, stores output in .csv-format and passes the Sequence IDs on into a .txt file for further queries.


# Pull base image.
FROM ubuntu:14.04.4
FROM ruby:2.1-onbuild

MAINTAINER Annemarie Eckes, Annemarie.Eckes@earlham.ac.uk

# clone repo
WORKDIR /tmp

COPY retrieve_phenotypes_and_ID.rb retrieve_phenotypes_and_ID.rb


#WORKDIR /tmp

RUN chmod +x retrieve_phenotypes_and_ID.rb   #to remove permission error
RUN ruby retrieve_phenotypes_and_ID.rb

ENTRYPOINT ["/tmp/retrieve_phenotypes_and_ID.rb"]
