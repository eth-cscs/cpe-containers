help("Load cuda environment")

local PREFIX = "/usr/local/cuda"
setenv("CUDA_HOME", PREFIX)
prepend_path("PATH", PREFIX .. "/bin")
prepend_path("LIBRARY_PATH", PREFIX .. "/lib64")
prepend_path("LIBRARY_PATH", PREFIX .. "/lib64/stubs")
