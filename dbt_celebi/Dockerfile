##
#  Generic dockerfile for dbt image building.
#  See README for operational details
##
# Top level build args
ARG build_for=linux/amd64
##
# base image (abstract)
FROM ghcr.io/dbt-labs/dbt-core:1.8.0
##
# N.B. The refs updated automagically every release via bumpversion
# N.B. dbt-postgres is currently found in the core codebase so a value of dbt-core@<some_version> is correct
ENV dbt_core_ref dbt-core@v1.3.0b1
ENV dbt_postgres_ref dbt-core@v1.3.0b1
ENV dbt_redshift_ref dbt-redshift@v1.3.0b1
ENV dbt_bigquery_ref dbt-bigquery@v1.3.0b1
ENV dbt_snowflake_ref dbt-snowflake@v1.3.0b1
ENV dbt_spark_ref dbt-spark@v1.3.0b1
# special case args
ENV dbt_spark_version all
#ENV dbt_third_party dbt-third-party
#
#
#
## System setup
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    git \
    ssh-client \
    software-properties-common \
    make \
    build-essential \
    ca-certificates \
    libpq-dev \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*


RUN pip install --upgrade pip && \
    pip install dbt-adapters==1.1.1 && \
    pip install dbt-common==1.0.4 && \
    pip install dbt-extractor==0.5.1 && \
    pip install dbt-semantic-interfaces==0.5.1 && \
    pip install --upgrade dbt-bigquery && \
    pip install --upgrade slack-sdk && \
    pip install 'elementary-data[bigquery]==0.14.1'

COPY / ./

# Separate bucket name is needed as bucket name is universal and unique
ENV prod_bucket_name "dbt-celebi-artifacts"

RUN dbt deps
ENTRYPOINT ["bash"]