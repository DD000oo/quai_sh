#!/bin/bash

# 在出错时退出脚本
set -e

# 记录脚本开始时间
start_time=$(date +"%T")
echo "Script started at $start_time"

# 更新和升级Ubuntu软件包
sudo apt update && sudo apt upgrade -y

# 安装必要的软件包
sudo apt install -y git cmake build-essential mesa-common-dev screen nano

# 检查git命令是否存在
if ! command -v git &> /dev/null; then
    echo "git is not installed. Exiting."
    exit 1
fi

# 克隆指定的git仓库并进入相应目录
REPO_DIR="quai-gpu-miner"
if [ ! -d "$REPO_DIR" ]; then
    git clone https://github.com/DD000oo/quai-gpu-miner.git
fi
cd $REPO_DIR

# 更新git子模块
git submodule update --init --recursive

echo "-------------------------"
echo -e "\e[31mCurrent Directory: $(pwd)\e[0m"
echo "-------------------------"

# 创建build目录并进入
BUILD_DIR="build"
if [ ! -d "$BUILD_DIR" ]; then
    mkdir $BUILD_DIR
fi
cd $BUILD_DIR

# 运行cmake命令
cmake .. && cmake --build .

echo "-------------------------"
echo -e "\e[31mCurrent Directory: $(pwd)\e[0m"
echo "-------------------------"

# 创建test.sh文件
TEST_SCRIPT="test.sh"
if [ ! -f "$TEST_SCRIPT" ]; then
    echo "#!/bin/bash
    while [ 1 ];
    do
        sleep 2
        ./ethcoreminer/ethcoreminer -P stratum://47.253.41.254:3333 -L 1 && break
    done" > $TEST_SCRIPT
fi

# 使test.sh可执行
chmod +x $TEST_SCRIPT

# 使用screen命令
if command -v screen &> /dev/null; then
    screen -R gpu
else
    echo "screen is not installed. Skipping."
fi

# 记录脚本结束时间
end_time=$(date +"%T")
echo "Script finished at $end_time"
