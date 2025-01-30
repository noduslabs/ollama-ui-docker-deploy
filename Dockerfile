# the open-source repository from open-webui that pulls both the open-webui with latest ollama image bundled
FROM ghcr.io/open-webui/open-webui:latest-ollama

# the default model to use. see the full list on https://ollama.com/search (click on the model to get its name)
ARG MODEL_NAME=deepseek-r1:8b 

# keep connections alive indefinitely
ENV OLLAMA_KEEP_ALIVE -1

# where the models are stored
ENV OLLAMA_MODELS=/ollama/models

# run the model, wait, and then pull the model
RUN ollama serve & sleep 5 && ollama pull $MODEL_NAME
