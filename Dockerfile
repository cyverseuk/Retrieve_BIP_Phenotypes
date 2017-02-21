# Docker container for retrieveing Phenotypic data from the Brassica Information Portal.
# It uses the BIP-API, stores output in .csv-format and passes the Sequence IDs on into a .txt file for further queries.


# Pull base image.
FROM ruby:2.1-onbuild

MAINTAINER Annemarie Eckes, Annemarie.Eckes@earlham.ac.uk

# clone repo
WORKDIR /tmp

COPY retrieve_phenotypes_and_ID.rb /tmp/retrieve_phenotypes_and_ID.rb
COPY retrieve_trial.sh /tmp/retrieve_trial.sh

#WORKDIR /tmp

RUN chmod +x retrieve_phenotypes_and_ID.rb   #to remove permission error
RUN chmod +x retrieve_trial.sh

ENTRYPOINT ["/tmp/retrieve_trial.sh"]
