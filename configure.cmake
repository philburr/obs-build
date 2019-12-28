set(PREFIX PREFIX)
configure_file(${NVENC_SOURCE_DIR}/ffnvcodec.pc.in ffnvcodec.pc.in @ONLY)
set(PREFIX ${NVENC_SOURCE_DIR})
configure_file(${CMAKE_CURRENT_BINARY_DIR}/ffnvcodec.pc.in ffnvcodec.pc @ONLY)