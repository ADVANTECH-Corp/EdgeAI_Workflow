# How to Run an LLM Model with GenieX

## Overview

This guide provides a simple path to run a Large Language Model (LLM) with Qualcomm AI Hub GenieX in a Docker container. For complete installation and execution instructions, follow the linked Qualcomm documentation.

* Application: Generative AI 
* Platform: Qualcomm Dragonwing IQ-9075
* OS: Ubuntu 24.04

## 1. Install GenieX with Docker

Follow the official [Linux (Docker) Install](https://geniex.aihub.qualcomm.com/en/run/linux/install) guide to pull the GenieX container image and start a container with NPU access.

## 2. Run a Qualcomm AI Hub Model

After entering the GenieX container, follow the official [Run a Qualcomm AI Hub Model](https://geniex.aihub.qualcomm.com/en/models/supported#run-a-qualcomm-ai-hub-model) guide to run `Qwen3-4B` with GenieX.

To run a different model, select one from [Qualcomm AI Hub Models for IQ-9075](https://aihub.qualcomm.com/models?domain=Generative+AI&useCase=Text+Generation&chipsets=qualcomm-qcs9075), open its model page, and check the `Quick Start` section for GenieX support.
