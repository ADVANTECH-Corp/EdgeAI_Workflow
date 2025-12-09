// SNPEPipeline.cpp
#include "SNPEPipeline.hpp"

#include <algorithm>
#include <cctype>
#include <iostream>
#include <stdexcept>
#include <vector>

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable:4267)
#endif

#include "DlContainer/IDlContainer.hpp"
#include "SNPE/SNPE.hpp"
#include "SNPE/SNPEFactory.hpp"
#include "DlSystem/DlError.hpp"
#include "DlSystem/ITensor.hpp"
#include "DlSystem/RuntimeList.hpp"
#include "DlSystem/String.hpp"
#include "DlSystem/StringList.hpp"
#include "DlSystem/TensorMap.hpp"
#include "DlSystem/TensorShape.hpp"

namespace snpe {

SNPEPipeline::SNPEPipeline() {
    m_snpe       = nullptr;
    m_container  = nullptr;
    m_input_tensor.reset();
    m_outputs.clear();
    m_runtim = zdl::DlSystem::Runtime_t::CPU;
}

static std::unique_ptr<zdl::SNPE::SNPE>
try_build(zdl::DlContainer::IDlContainer* container,
          const zdl::DlSystem::RuntimeList& runtimes,
          const std::vector<std::string>& layer_names,
          std::string* err)
{
    zdl::SNPE::SNPEBuilder b(container);
    if (!layer_names.empty()) {
        zdl::DlSystem::StringList outLayers;
        for (const auto& s : layer_names) outLayers.append(s.c_str());
        auto snpe = b.setRuntimeProcessorOrder(runtimes)
                     .setUseUserSuppliedBuffers(false)
                     .setPerformanceProfile(zdl::DlSystem::PerformanceProfile_t::HIGH_PERFORMANCE)
                     .setOutputLayers(outLayers)
                     .build();
        if (!snpe && err) *err = zdl::DlSystem::getLastErrorString();
        return snpe;
    } else {
        auto snpe = b.setRuntimeProcessorOrder(runtimes)
                     .setUseUserSuppliedBuffers(false)
                     .setPerformanceProfile(zdl::DlSystem::PerformanceProfile_t::HIGH_PERFORMANCE)
                     .build();
        if (!snpe && err) *err = zdl::DlSystem::getLastErrorString();
        return snpe;
    }
}




bool SNPEPipeline::init(const std::string &model_path, 
                        const std::string &device,
                        const std::vector<std::string>& layer_names)
{
    // Display SNPE version information
    static zdl::DlSystem::Version_t version = zdl::SNPE::SNPEFactory::getLibraryVersion();
    std::cout << "[SNPE] Version: " << version.asString().c_str() << std::endl;

    std::string device_upper = device;
    std::transform(device_upper.begin(), device_upper.end(), device_upper.begin(),
                   [](unsigned char c){ return (unsigned char)std::toupper(c); });
    if (device_upper == "DSP") {
        if (zdl::SNPE::SNPEFactory::isRuntimeAvailable(zdl::DlSystem::Runtime_t::DSP)) {
            m_runtim = zdl::DlSystem::Runtime_t::DSP;
            std::cout << "[SNPE] Runtime: DSP\n";
        } else {
            std::cerr << "[SNPE][warn] DSP runtime not available, fallback to CPU\n";
            m_runtim = zdl::DlSystem::Runtime_t::CPU;
        }
    } else if (device_upper == "GPU") {
        if (zdl::SNPE::SNPEFactory::isRuntimeAvailable(zdl::DlSystem::Runtime_t::GPU)) {
            m_runtim = zdl::DlSystem::Runtime_t::GPU;
            std::cout << "[SNPE] Runtime: GPU\n";
        } else {
            std::cerr << "[SNPE][warn] GPU runtime not available, fallback to CPU\n";
            m_runtim = zdl::DlSystem::Runtime_t::CPU;
        }
    } else {
        m_runtim = zdl::DlSystem::Runtime_t::CPU;
        std::cout << "[SNPE] Runtime: CPU\n";
    }

    // Open the DLC
    m_container = zdl::DlContainer::IDlContainer::open(model_path);
    if (!m_container) {
        std::cerr << "[SNPE][error] Failed to open container: " << model_path << "\n";
        std::cerr << "[SNPE] Last Error: " << zdl::DlSystem::getLastErrorString() << "\n";
        return false;
    }

    // Prepare the runtime list
    zdl::DlSystem::RuntimeList runtimes;
    runtimes.add(m_runtim);
    runtimes.add(zdl::DlSystem::Runtime_t::CPU); // fallback

    if (layer_names.empty()) {
        std::cout << "[SNPE] No output layers specified, using default outputs." << std::endl;
    } else {
        std::cout << "[SNPE] Trying output LAYERS:";
        for (const auto& n : layer_names) std::cout << " " << n;
        std::cout << std::endl;
    }

    // Create the StringList
    zdl::DlSystem::StringList outputLayers;
    for (const auto &name : layer_names)
        outputLayers.append(name.c_str());

    // Create the SNPE Builder and specify the output layers
    zdl::SNPE::SNPEBuilder builder(m_container.get());

    if (!layer_names.empty()) {
        m_snpe = builder
            .setRuntimeProcessorOrder(runtimes)
            .setUseUserSuppliedBuffers(false)
            .setPerformanceProfile(zdl::DlSystem::PerformanceProfile_t::HIGH_PERFORMANCE)
            .setOutputLayers(outputLayers)
            .build();
    }

    if (!m_snpe) {
        if (!layer_names.empty()) {
            std::cerr << "[SNPE][warn] build with specified layers failed: "
                      << zdl::DlSystem::getLastErrorString() << "\n"
                      << "[SNPE] Fallback to default output layers." << std::endl;
        }
        
        zdl::SNPE::SNPEBuilder builder_default(m_container.get());
        m_snpe = builder_default
            .setRuntimeProcessorOrder(runtimes)
            .setUseUserSuppliedBuffers(false)
            .setPerformanceProfile(zdl::DlSystem::PerformanceProfile_t::HIGH_PERFORMANCE)
            .build();
    }

    if (!m_snpe) {
        std::cerr << "[SNPE][error] Failed to build SNPE network (even with fallback).\n";
        std::cerr << "[SNPE] Last Error: " << zdl::DlSystem::getLastErrorString() << "\n";
        return false;
    }

    // Print the names of the actually allocated output tensors
    auto outNamesOpt = m_snpe->getOutputTensorNames();
    if (outNamesOpt) {
        const auto& outNames = *outNamesOpt;
        std::cout << "[SNPE] Configured output tensors (" << outNames.size() << "):\n";
        for (auto it = outNames.begin(); it != outNames.end(); ++it) {
            std::cout << "  - " << *it << "\n";
        }
    } else {
        std::cout << "[SNPE] getOutputTensorNames() returned empty.\n";
    }

    // Print input tensor information
    auto inNamesOpt = m_snpe->getInputTensorNames();
    if (inNamesOpt) {
        const auto& inNames = *inNamesOpt;
        for (auto it = inNames.begin(); it != inNames.end(); ++it) {
            const char* nm = *it;
            auto dimsOpt = m_snpe->getInputDimensions(nm);
            if (dimsOpt) {
                const zdl::DlSystem::TensorShape& dims = *dimsOpt;
                size_t rank = dims.rank();
                size_t total = 1;
                for (size_t i = 0; i < rank; ++i)
                    total *= (size_t)dims[i];
                std::cout << "[SNPE] Input tensor: " << nm << " | shape=[";
                for (size_t i = 0; i < rank; ++i) {
                    std::cout << dims[i];
                    if (i + 1 < rank) std::cout << ",";
                }
                std::cout << "] (" << total << " elements)\n";
            }
        }
    }

    return true;
}

void SNPEPipeline::loadInputTensor(std::vector<float> &input_vec) {
    if (!m_snpe) throw std::runtime_error("SNPE not initialized");

    if (!m_input_tensor) {
        const auto &strList_opt = m_snpe->getInputTensorNames();
        if (!strList_opt) throw std::runtime_error("failed to get input tensor names");
        const auto &strList = *strList_opt;
        const auto &inputDims_opt = m_snpe->getInputDimensions(strList.at(0));
        if (!inputDims_opt) throw std::runtime_error("failed to get input dims");
        const auto &input_shape = *inputDims_opt;
        m_input_tensor = zdl::SNPE::SNPEFactory::getTensorFactory().createTensor(input_shape);
        if (!m_input_tensor) throw std::runtime_error("failed to create input tensor");
    }

    const size_t need = m_input_tensor->getSize();
    if (need != input_vec.size()) {
        std::cerr << "[SNPE][error] Input tensor size mismatch. expected=" << need
                  << ", got=" << input_vec.size() << "\n";
        return;
    }
    std::copy(input_vec.begin(), input_vec.end(), m_input_tensor->begin());
}

bool SNPEPipeline::getInputSize(int& width, int& height, int& channels) const
{
    if (!m_snpe) return false;

    auto inNamesOpt = m_snpe->getInputTensorNames();
    // if (!inNamesOpt || inNamesOpt->size() == 0) return false;

    const auto& inNames = *inNamesOpt;
    auto dimsOpt = m_snpe->getInputDimensions(inNames.at(0));
    if (!dimsOpt) return false;

    const zdl::DlSystem::TensorShape& dims = *dimsOpt;

    if (dims.rank() == 4) {
        height   = (int)dims[1];
        width    = (int)dims[2];
        channels = (int)dims[3];
        return true;
    }
    return false;
}


void SNPEPipeline::getOutputTensors(std::vector<OutputTensor> &outputs) {
    outputs.clear();
    outputs = m_outputs;
}

bool SNPEPipeline::execute() {
    if (!m_snpe) {
        std::cerr << "[SNPE][error] SNPE not initialized\n";
        return false;
    }
    if (!m_input_tensor) {
        std::cerr << "[SNPE][error] Input tensor is not initialized\n";
        return false;
    }

    static zdl::DlSystem::TensorMap input_map;
    static zdl::DlSystem::TensorMap output_map;
    input_map.clear();
    output_map.clear();

    auto inNamesOpt = m_snpe->getInputTensorNames();
    const auto& inNames = *inNamesOpt;
    input_map.add(inNames.at(0), m_input_tensor.get());

    const bool ok = m_snpe->execute(input_map, output_map);
    if (!ok) {
        std::cerr << "[SNPE][error] execute() failed\n";
        std::cerr << "[SNPE] Last Error: " << zdl::DlSystem::getLastErrorString() << "\n";
        return false;
    }

    zdl::DlSystem::StringList outNames = output_map.getTensorNames();

    m_outputs.clear();
    m_outputs.reserve(outNames.size());

    for (auto it = outNames.begin(); it != outNames.end(); ++it) {
        const char* name = *it;
        auto tensorPtr = output_map.getTensor(name);
        if (!tensorPtr) continue;

        const zdl::DlSystem::TensorShape& dims = tensorPtr->getShape();
        size_t rank = dims.rank();

        size_t total = 1; for (size_t i=0;i<rank;++i) total *= (size_t)dims[i];

        OutputTensor out_tensor;
        out_tensor.name = name;
        for (size_t i=0; i<rank; ++i) out_tensor.shape.push_back(dims[i]);

        out_tensor.data.resize(total);
        size_t i = 0;
        for (auto tIt = tensorPtr->cbegin(); tIt != tensorPtr->cend(); ++tIt) {
            out_tensor.data[i++] = *tIt;
        }

        m_outputs.push_back(std::move(out_tensor));
    }

    return true;
}

} // namespace snpe

#ifdef _MSC_VER
#pragma warning(pop)
#endif