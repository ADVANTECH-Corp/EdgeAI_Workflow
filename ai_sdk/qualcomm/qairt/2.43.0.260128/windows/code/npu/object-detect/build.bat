rd /s /q build
mkdir build
cd build
cmake -G "Visual Studio 17 2022" -A ARM64 -T host=x64 ..
cmake --build . --config Release -- /m
cd ..