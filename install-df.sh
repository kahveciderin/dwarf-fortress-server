failed=
trap 'failed=yes' ERR

mkdir ~/dwarf_fortress 2> /dev/null || echo "Dwarf fortress directory already exists, skipping..."
mkdir ~/dwarf_fortress/saves 2> /dev/null || echo "Save directory already exists, skipping..."
mkdir df_install
cd df_install
wget https://raw.githubusercontent.com/kahveciderin/dwarf-fortress-server/master/Dockerfile
docker build -t dfserver .
docker run -d --restart always --privileged -p 8765:1234 -p 5000:5000 -v ~/dwarf_fortress/saves:/df/df_linux/data/save -it dfserver
cd ..
rm -rf df_install/
if [ -z "$failed" ]; then
    echo "Server should be up and running on port 8765!"
else
    echo "Encountered error, deleting created docker container"
    docker stop dfserver
    docker rm dfserver