# This uses the latest Docker image built from the samples repository,
# defined by the Dockerfile in Build/images/samples.
FROM mcr.microsoft.com/quantum/iqsharp-base:0.18.2106148006

# Mark that this Dockerfile is used with the samples repository.
ENV IQSHARP_HOSTING_ENV=SAMPLES_HOSTED

# Make sure the contents of our repo are in ${HOME}.
# These steps are required for use on mybinder.org.
USER root
COPY . ${HOME}
RUN chown -R ${USER} ${HOME}

# FIXME: The following is a workaround for https://github.com/microsoft/iqsharp/issues/404,
#        and should be removed when that issue is resolved.
RUN chown -R ${USER}:${USER} /home/${USER}/.azure

# Finish by dropping back to the notebook user.
USER ${USER}
