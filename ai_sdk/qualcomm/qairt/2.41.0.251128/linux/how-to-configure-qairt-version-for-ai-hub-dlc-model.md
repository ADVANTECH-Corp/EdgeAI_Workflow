# Configure the QAIRT Version for an AI Hub DLC Model on Qualcomm IQ9075 (Ubuntu)

Qualcomm AI Hub uses a specific QAIRT version when generating a `.dlc` model. 
Before running the model, confirm that the corresponding QAIRT version is available on the device.

#### Step 1. Check the Model QAIRT Version

Open the metadata file included with the model. Find `tool_versions` and check the `qairt` value.

- Example:
    ```json
    "tool_versions": {
        "qairt": "2.45.0.260326154327"
    }
    ```

Record the QAIRT version used to generate the model.

#### Step 2. Check the QAIRT Versions on the Device

- Run:
    ```bash
    ls /opt/qcom/aistack/qairt/
    ```

- Example:
    ```text
    2.41.0.251128
    ```

- In this example:
    ```text
    Model QAIRT version:  2.45.0.260326154327
    Device QAIRT version: 2.41.0.251128
    ```

The QAIRT version required by the model is not currently available on the device.

#### Step 3. Download the Required QAIRT Version

Open the Qualcomm AI Runtime Community download page:

https://qpm.qualcomm.com/#/main/tools/details/Qualcomm_AI_Runtime_Community

> A Qualcomm account is required to download QAIRT. \
> If you do not have a Qualcomm account, create one and sign in.

![image (2)](../../../assets/qairt_download_page.png)
Select and download the QAIRT version corresponding to the version shown in the model metadata.

#### Step 4. Install QAIRT on the Device

After downloading the QAIRT package, extract the complete QAIRT directory to:

```text
/opt/qcom/aistack/qairt/
```

- Example:
    ```text
    /opt/qcom/aistack/qairt/2.45.0.260326
    ```

#### Step 5. Confirm the Installation

- Run:
    ```bash
    ls /opt/qcom/aistack/qairt/
    ```

- Example:
    ```text
    2.41.0.251128
    2.45.0.260326
    ```

Confirm that the required QAIRT version is now available.

#### Step 6. Configure the QAIRT Environment

The following example is for IQ9075:

```bash
export QAIRT_HOME="/opt/qcom/aistack/qairt/2.45.0.260326"
export QAIRT_TARGET_ARCH="aarch64-oe-linux-gcc11.2"
export QAIRT_HEXAGON_ARCH="hexagon-v73"

export PATH="${QAIRT_HOME}/bin/${QAIRT_TARGET_ARCH}:${PATH}"
export LD_LIBRARY_PATH="${QAIRT_HOME}/lib/${QAIRT_TARGET_ARCH}:${LD_LIBRARY_PATH}"
export ADSP_LIBRARY_PATH="${QAIRT_HOME}/lib/${QAIRT_HEXAGON_ARCH}/unsigned"

```

For another Qualcomm platform, confirm the correct `target architecture` and `Hexagon version` before configuring the environment.

#### Step 7. Confirm the Active QAIRT Version

- Run:
    ```bash
    snpe-net-run --version
    ```

The executable path and version should point to the QAIRT version selected for the model.

The DLC model can now be executed using this QAIRT environment.
