cmake_minimum_required(VERSION 3.12)

include(ExternalProject)
ExternalProject_Add(ffmpeg
	GIT_REPOSITORY https://github.com/philburr/FFmpeg.git
	GIT_TAG master
	CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX} --extra-libs="-lpthread" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree --enable-shared
	BUILD_COMMAND make
	BUILD_IN_SOURCE 1
	INSTALL_COMMAND make install
)

ExternalProject_Add(obs
	GIT_REPOSITORY https://github.com/obsproject/obs-studio
	GIT_TAG master
	CMAKE_ARGS -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)
ExternalProject_Get_property(obs SOURCE_DIR)
set(OBS_SOURCE_DIR ${SOURCE_DIR})

ExternalProject_Add(obs-atsc
	GIT_REPOSITORY https://github.com/philburr/obs-atsc
	GIT_TAG master
	CMAKE_ARGS -DOBS_SOURCE_DIR=${OBS_SOURCE_DIR} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)


add_library(build INTERFACE)
add_dependencies(build ffmpeg obs obs-atsc)