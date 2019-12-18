# Start from the IQ# base image. The definition for this image can be found at
# https://github.com/microsoft/iqsharp/blob/master/images/iqsharp-base/Dockerfile.
# As per Binder documentation, we choose to use an SHA sum here instead of a
# tag.
FROM mcr.microsoft.com/quantum/iqsharp-base:0.10.1912.0501

# Mark that this Dockerfile is used with the samples repository.
ENV IQSHARP_HOSTING_ENV=SAMPLES_DOCKERFILE

# We need to do a few additional things as root here.
USER root

# Install additional system packages from apt.
RUN apt-get -y update && \
    apt-get -y install \
               # For the chemistry samples, we'll need PowerShell to be
               # installed.
               powershell \
               # For the Python interoperability sample, we require QuTiP,
               # which in turn requires gcc's C++ support.
               g++ \
               # The version of Matplotlib we use also needs a couple header
               # packages.
               pkg-config \
               libfreetype6-dev \
               libpng-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# Install additional Python dependencies for the PythonInterop sample.
# Note that QuTiP has as a hard requirement that its dependencies must be
# installed first, so we separate into two pip install steps.
RUN pip install cython \
                numpy \
                scipy && \
    pip install qutip
# We install the rest of our Python dependencies as a separate layer since
# building QuTiP can take a few moments. This makes it easier if we want to add
# other Python packages later.
RUN pip install "matplotlib<=2.1.2" \
                "ipyparallel" \
                "mpltools" \
                "qinfer"

# Finish by dropping back to the notebook user.
USER ${USER}
