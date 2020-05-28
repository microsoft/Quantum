FROM mcr.microsoft.com/quantum/iqsharp-base:0.11.2004.2825

USER root
RUN pip install rise matplotlib numpy

USER ${USER}
ADD --chown=jovyan HalfMoons.ipynb data.json Training.qs /home/${USER}/demo/

CMD [ "jupyter", "notebook" , "--ip=0.0.0.0" ]
