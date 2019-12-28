cmake_minimum_required(VERSION 3.12)

include(ExternalProject)

ExternalProject_Add(nvenc
	GIT_REPOSITORY https://github.com/FFmpeg/nv-codec-headers
	GIT_TAG master
	CONFIGURE_COMMAND ""
	BUILD_COMMAND ""
	INSTALL_COMMAND ""
)
ExternalProject_Get_property(nvenc SOURCE_DIR)
set(NVENC_SOURCE_DIR ${SOURCE_DIR})

add_custom_target(nvenc-configure
	DEPENDS
		${CMAKE_CURRENT_SOURCE_DIR}/configure.cmake
	COMMAND
		${CMAKE_COMMAND} -DNVENC_SOURCE_DIR=${NVENC_SOURCE_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/configure.cmake
)
add_dependencies(nvenc-configure nvenc)

ExternalProject_Add(ffmpeg
	GIT_REPOSITORY https://github.com/philburr/FFmpeg.git
	GIT_TAG master
	CONFIGURE_COMMAND PKG_CONFIG_PATH=${CMAKE_CURRENT_BINARY_DIR} ./configure --prefix=${CMAKE_INSTALL_PREFIX} --extra-cflags="-I${NVENC_SOURCE_DIR}/include" --extra-libs="-lpthread" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nvenc --enable-nonfree --enable-shared
	BUILD_COMMAND make
	BUILD_IN_SOURCE 1
	INSTALL_COMMAND make install
)
add_dependencies(ffmpeg nvenc-configure)

ExternalProject_Add(obs
	GIT_REPOSITORY https://github.com/obsproject/obs-studio
	GIT_TAG master
	CMAKE_ARGS -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)
ExternalProject_Get_property(obs SOURCE_DIR)
set(OBS_SOURCE_DIR ${SOURCE_DIR})
add_dependencies(obs ffmpeg)

ExternalProject_Add(obs-atsc
	GIT_REPOSITORY https://github.com/philburr/obs-atsc
	GIT_TAG master
	CMAKE_ARGS -DOBS_SOURCE_DIR=${OBS_SOURCE_DIR} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)
add_dependencies(obs-atsc obs)

ExternalProject_Add(obs-websocket
	GIT_REPOSITORY https://github.com/philburr/obs-websocket.git
	GIT_TAG origin/4.x-current
	CMAKE_ARGS -DLIBOBS_INCLUDE_DIR=${OBS_SOURCE_DIR}/libobs -DLIBOBS_LIB=${CMAKE_INSTALL_PREFIX}/lib/libobs.so -DOBS_FRONTEND_LIB=${CMAKE_INSTALL_PREFIX}/lib/libobs-frontend-api.so -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)
add_dependencies(obs-websocket obs)

add_library(build INTERFACE)
add_dependencies(build ffmpeg obs obs-atsc obs-websocket)
