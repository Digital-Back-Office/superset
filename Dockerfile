# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

######################################################################
# Node stage to deal with static asset construction
######################################################################

# if BUILDPLATFORM is null, set it to 'amd64' (or leave as is otherwise).
ARG BASE_IMAGE=dataflowrepo/dataflow-base
ARG BASE_IMAGE_TAG=latest
ARG BUILDPLATFORM=${BUILDPLATFORM:-linux/x86_64}

FROM --platform=${BUILDPLATFORM} node:20-bullseye-slim AS superset-node

RUN apt-get update \
    && apt-get install \
        -y --no-install-recommends \
        build-essential \
        python3 git zstd ca-certificates -y

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

WORKDIR /app/superset-frontend

COPY superset-frontend /app/superset-frontend

RUN npm ci \
&& npm run build 

COPY superset/translations /app/superset/translations
RUN npm run build-translation \
&& rm /app/superset/translations/*/LC_MESSAGES/*.po \
&& rm /app/superset/translations/messages.pot

######################################################################
# Final lean image...
######################################################################
FROM --platform=${BUILDPLATFORM} ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS lean 

WORKDIR /app
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_HOME=/home/jovyan \
    SUPERSET_ENV=production \
    FLASK_APP="superset.app:create_app()" \
    PYTHONPATH="/app/pythonpath" \
    SUPERSET_HOME="/app/superset_home" \
    PATH=/dataflow/python-envs/superset-env/bin:${NB_HOME}/bin:${PATH} \
    SUPERSET_CONFIG_PATH="/app/superset_config.py"

RUN apt-get update -y \
&& adduser --uid ${NB_UID} \
    --home ${NB_HOME} \
    --shell /bin/bash \
    --disabled-password \
    --gecos "Default user" \
    ${NB_USER} \
&& install -d -m 0755 -o ${NB_USER} -g ${NB_USER} ${NB_HOME}

#Installing dependencies for superset
RUN mkdir -p ${PYTHONPATH} ${SUPERSET_HOME} superset/static requirements superset-frontend apache_superset.egg-info \
&& chown -R ${NB_USER}:${NB_USER} ${SUPERSET_HOME} \
&& apt-get install -y --no-install-recommends \
    build-essential git \
    default-libmysqlclient-dev \
    libsasl2-dev \
    libsasl2-modules-gssapi-mit \
    libpq-dev \
    libecpg-dev \
    libldap2-dev \
&& touch superset/static/version_info.json \
&& chown -R ${NB_USER}:${NB_USER} ./* \
&& rm -rf /var/lib/apt/lists/* \
&& conda create --prefix /dataflow/python-envs/superset-env python=3.10 -v -y \
&& conda clean -ay

#Copying required files from local
COPY --chown=${NB_USER}:${NB_USER} pyproject.toml setup.py MANIFEST.in superset_config.py ./
COPY --chown=${NB_USER}:${NB_USER} superset-frontend/package.json superset-frontend/
COPY --chown=${NB_USER}:${NB_USER} requirements/base.txt requirements/
RUN --mount=type=cache,target=/root/.cache/pip pip install --upgrade setuptools pip \
&& pip install -r requirements/base.txt \
&& pip install 'git+https://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@github.com/Digital-Back-Office/dataflow-core.git@v2.0.0' psycopg2-binary \
&& pip cache purge \
&& rm -rf /var/lib/apt/lists/*

#Copying all backend files
COPY --chown=${NB_USER}:${NB_USER} superset superset

#Copying all frontend files
COPY --chown=${NB_USER}:${NB_USER} --from=superset-node /app/superset/static/assets superset/static/assets

#Installing superset
COPY --chown=${NB_USER}:${NB_USER} scripts/translations/generate_mo_files.sh scripts/translations/
RUN pip install -e . \
&& ./scripts/translations/generate_mo_files.sh

USER ${NB_USER}

EXPOSE 8088