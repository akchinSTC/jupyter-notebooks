FROM quay.io/odh-jupyterhub/s2i-minimal-notebook:3.6

# Elyra requires nodejs v12+
RUN wget https://nodejs.org/dist/v12.18.3/node-v12.18.3-linux-x64.tar.xz && tar -xvf node-v12.18.3-linux-x64.tar.xz
ENV PATH="/opt/app-root/src/node-v12.18.3-linux-x64/bin:${PATH}"

COPY requirements-elyra.txt requirements-elyra.txt

RUN pip install -r requirements-elyra.txt

RUN pip install --upgrade --pre elyra && jupyter lab build

RUN fix-permissions /opt/app-root

# ADD FILES AS LATE AS POSSIBLE TO AVOID BLOWING UP DOCKER LAYERS
COPY start-singleuser.sh setup-elyra-metadata.sh /opt/app-root/bin/

USER root
RUN chmod 775 /opt/app-root/bin/start-singleuser.sh && \
    chown default:root /opt/app-root/bin/start-singleuser.sh

# TEMPORARY FIX FOR ELYRA ISSUE #792
RUN sed -i 's/running/event/g' /opt/app-root/lib/python3.6/site-packages/elyra/pipeline/processor.py

RUN chmod 775 /opt/app-root/bin/setup-elyra-metadata.sh && \
    chown default:root /opt/app-root/bin/setup-elyra-metadata.sh
USER default


