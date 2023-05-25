
FROM train

# user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# set user
USER $USERNAME

# entrypoint
WORKDIR /app/
COPY --chown=$USERNAME infer.entry.sh .
RUN chmod +x infer.entry.sh

ENTRYPOINT ["/bin/bash", "-c", "./infer.entry.sh"]
