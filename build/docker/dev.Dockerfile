# ARG USERNAME=dev
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID

FROM node:24.2-bookworm AS base
RUN apt-get update -y
RUN apt-get install -y python3.11 python3.11-venv python3-pip

COPY ../../backend/requirements.txt /opt/venv/requirements.txt
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN python3 -m pip install -r /opt/venv/requirements.txt

# USER $USERNAME

FROM base