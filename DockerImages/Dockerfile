FROM fedora:27

RUN dnf -y update
RUN dnf -y install wget ipython3 libgomp

# Configure the dnf repo for dotnet
WORKDIR /tmp/
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN wget -q https://packages.microsoft.com/config/fedora/27/prod.repo
RUN mv prod.repo /etc/yum.repos.d/microsoft-prod.repo
RUN chown root:root /etc/yum.repos.d/microsoft-prod.repo

# Update and install Q# SDK
RUN dnf install -y dotnet-sdk-2.2
RUN dotnet new -i Microsoft.Quantum.ProjectTemplates

RUN pip3 install jupyter
# This is needed because of a bug in jupyter.
# https://github.com/jupyter/jupyter_console/issues/158
RUN pip3 install 'prompt-toolkit==1.0.15'

# Install and configure the Q# python interopts
RUN dotnet tool install -g Microsoft.Quantum.IQSharp
RUN pip3 install qsharp 
# We need the full path here because this isn't added to the path until the
# shell reloads.
RUN /root/.dotnet/tools/dotnet-iqsharp install

# Add the example Jupyter notebook for testing
ADD Inline.ipynb /root/

WORKDIR /root/
