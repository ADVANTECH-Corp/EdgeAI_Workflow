// SNPEPipeline.hpp
#ifndef SNPE_PIPELINE_HPP_
#define SNPE_PIPELINE_HPP_

#include <string>
#include <vector>
#include <iostream>
#include <algorithm>
#include <memory> 
#include <map>

#include "SNPE/SNPE.hpp"
#include "SNPE/SNPEFactory.hpp"
#include "SNPE/SNPEBuilder.hpp" 

// 系統 API
#include "DlSystem/DlEnums.hpp"
#include "DlSystem/ITensor.hpp"
#include "DlSystem/ITensorFactory.hpp"
#include "DlSystem/StringList.hpp"
#include "DlSystem/TensorMap.hpp"
#include "DlContainer/IDlContainer.hpp"
#include "DlSystem/IBufferAttributes.hpp" 
#include "DlSystem/RuntimeList.hpp"       


namespace snpe {

struct OutputTensor {
    std::string name;
    std::vector<size_t> shape; // e.g., [1, 10, 10, 255]
    std::vector<float> data;
};


class SNPEPipeline {
public:
    SNPEPipeline();
    
    bool init(const std::string &model_path, 
              const std::string &device, 
              const std::vector<std::string>& layer_names);

    bool isInit() { return m_snpe.get(); }
    void loadInputTensor(std::vector<float> &input_vec);
    bool getInputSize(int& width, int& height, int& channels) const;
    void getOutputTensors(std::vector<OutputTensor> &outputs);

    bool execute();

private:
    std::vector<OutputTensor> m_outputs; 

    zdl::DlSystem::Runtime_t m_runtim;
    std::unique_ptr<zdl::SNPE::SNPE> m_snpe;
    std::unique_ptr<zdl::DlContainer::IDlContainer> m_container;
    std::unique_ptr<zdl::DlSystem::ITensor> m_input_tensor;
};

} // namespace snpe

#endif // SNPE_PIPELINE_HPP_