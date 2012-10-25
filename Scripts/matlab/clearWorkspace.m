
function clearWorkspace()
    clc
    clear all
    com.mathworks.mlservices.MLCommandHistoryServices.removeAll
end