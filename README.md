# Deploy DeepSeek R1 with Ollama and Web UI via Docker

This Dockerfile instruction can be used to run an Ollama instance (which can be used to serve local open-source models, including DeepSeek R1) bundled with the Open-WebUI interface that provides ChatGPT-like access to the models and ability to upload your own knowledge bases. Useful for privacy and for the times when there's no internet.

There are multiple ways to run it: on your local machine, on a remote CPU server, or on a remote GPU server.

## Server

You can deploy Ollama on a server using the instructions at [https://noduslabs.com/featured/make-deepseek-ai-private/](https://noduslabs.com/featured/make-deepseek-ai-private/). Then you pull the model you need (e.g. DeepSeek) and can make it available to any location in the world for any device. 

### 1-Click Server Deployment

For an easy one-click deployment for testing, you can use Koyeb service provider based in France. 

The fastest one-click way of doing that is to use their automatic installation button: [https://www.koyeb.com/deploy/open-webui](https://www.koyeb.com/deploy/open-webui). 

Note, that an instance installed in this way will be not persistent, so if it goes down, you'll have to reload the models and create an admin account again. Do not share its address with others!

### Setting Up a Persistent Deployment

If you'd like to store the UI settings and the models (so you don't have to pull them every time the server restarts), you need to set up persistent storage for your instance. The easiest way to do that is to is to use Koyeb's "buttons", which is basically a URL instruction to set up the right server. You just replace the values and copy paste it in your browser to deploy the service. However, for more flexibilty you can use the Dockerfile instructions provided below, which gives you a more detailed control but also requires to install a command line tool from Koyeb and some work with this repo

#### Persistent Deployment (the easy way)

With this deployment you will have a PostreSQL instance that will save your UI settings (which is important if you customize your RAG, search, and knowledge base, as well as want to have multiple users and protect access)

1. Create a Koyeb Postgres database: `https://app.koyeb.com/database-services/new`. Get the database's login, password, and URL.

2. Deploy OpenWebUI with Ollama using the link below. Make sure to replace the `MODEL_NAME` with the model you'd like to use (we recommend `deepseek-r1:8b` as it runs on the weakest GPU and has a good quality) and the `DATABASE_URL` with the https://login:password@URL provided by the PostgreSQL instance you set up in step 1. Here's the link to use:
```
https://app.koyeb.com/deploy?name=openwebui-ollama-model-bundle&repository=koyeb%2Fexample-openwebui-ollama-model-bundle&branch=main&builder=dockerfile&instance_type=gpu-nvidia-rtx-4000-sff-ada&instances_min=0&env%5BDATABASE_URL%5D=REPLACE_ME&env%5BMODEL_NAME%5D=gemma2%3A2b&hc_grace_period%5B8000%5D=300
```


#### Persistent Deployment (for more control)

In this scenario, we can set up a proper volume with a storage to also store the models pulled and to ensure that our settings stay instact.

This Dockerfile can be used to set up a persistent instance that will maintain the default DeepSeek model you use and your user settings.

To do that:

1) Clone this repo

```
git clone git@github.com:noduslabs/ollama-ui-docker-deploy.git
```

2) Go to the folder:

```
cd ollama-ui-docker-deploy
```

3) Install Koyeb CLI:
```
brew install koyeb/tap/koyeb
```

4) Create a volume on Koyeb:
```
koyeb volume create openwebui-data --region fra --size 10
```

5) Deploy the Docker container to a new instance on Koyeb

You have 2 options:

a) A cheaper GPU (~$400 a month) with no volume to persist downloaded models — which means if the service crashes, it'll take some time to come up again and download the model and it will also lose the Web UI settings (including any users you created). In this case, you have to provide a link to your PostgreSQL service in your Dockerfile where all your data, including chats, will be stored. This is actually a good option because you are in full control in your data and you can decouple it from it the server.

```
koyeb deploy . openwebui/ollama-with-ui \
    --instance-type gpu-nvidia-rtx-4000-sff-ada \
    --region fra \
    --checks 8000:tcp \
    --checks-grace-period 8000=300 \
    --type web \
    --archive-builder docker \
    --archive-docker-dockerfile Dockerfile \
    --env MODEL_NAME=deepseek-r1:8b 
```
 
b) a more expensive GPU (~ $1500 a month) with a volume attached to persist your data - which means your server will retain the downloaded model even if it crashes as well as the user data. But they will be stored in the container. For more persistent storage, consider creating a PostgreSQL instance and providing its value in Dockerfile.
 
```
koyeb deploy . openwebui/ollama-with-ui \
    --instance-type gpu-nvidia-a100 \
    --region fra \
    --checks 8000:tcp \
    --checks-grace-period 8000=300 \
    --type web \
    --archive-builder docker \
    --archive-docker-dockerfile Dockerfile \
    --env MODEL_NAME=deepseek-r1:8b \
    --volumes openwebui-data:/app/backend/data
```

6) Log on to Koyeb's dashboard and check the URL to access to create an admin user for your Web UI.



## Local Machine

You can install everything manually following the installation instructions at [https://noduslabs.com/featured/make-deepseek-ai-private/](https://noduslabs.com/featured/make-deepseek-ai-private/) — you don't need this repo for it. This repo is useful if you just want to install everything in one go. 

You will need to use the Terminal and have `git` version control and `Docker` installed. 

1) Clone this repo running this command in Terminal:

```
git clone git@github.com:noduslabs/ollama-ui-docker-deploy.git
```

2) Go to the folder:

```
cd ollama-ui-docker-deploy
```

3) Inside the folder, run

```
docker run -d \
  --gpus=all \
  -v ollama:/root/.ollama \
  -v openwebui-data:/app/backend/data \
  -p 3005:8080 \
  -p 11434:11434 \
  --name ollama-webui \
  --restart always \
  my-ollama-webui
```

Note, if the command is not runnign, try to run it without the `--gpus=all` flag:

```
docker run -d \
  -v ollama:/root/.ollama \
  -v openwebui-data:/app/backend/data \
  -p 3005:8080 \
  -p 11434:11434 \
  --name ollama-webui \
  --restart always \
  my-ollama-webui
```

The local instance of Ollama with Deepseek R1:8B model downloaded will be available on  [https://localhost:3005](https://localhost:3005) in your browser.

Change the value of the port from `3005` to another if the former is taken. 

## Loading Models

You will be able to load more models at [https://localhost:3005](https://localhost:3005). 

## Providing Access to Other Devices in Your Local Network

To access it through other devices, go to the network settings of your computer, copy the address and add the port number and open it through your phone. E.g. `192.168.0.4:3005` (usually local addresses start with `192.168...`)
