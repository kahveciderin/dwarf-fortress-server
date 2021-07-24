mkdir ~/dwarf_fortress 2> /dev/null || echo "Dwarf fortress directory already exists, skipping..."
mkdir ~/dwarf_fortress/saves 2> /dev/null || echo "Save directory already exists, skipping..."
wget https://raw.githubusercontent.com/kahveciderin/dwarf-fortress-server/master/Dockerfile
docker build -t dfserver . && docker run --restart always --privileged -p 8765:1234 -v ~/dwarf_fortress/saves:/df/df_linux/data/save -it dfserver
echo "Server should be up and running!"