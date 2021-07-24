FROM ubuntu

WORKDIR /df

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install tar patch wget gcc cmake ninja-build git zlib1g-dev libsdl1.2-dev libxml-libxml-perl libxml-libxslt-perl -y

RUN git clone https://github.com/DFHack/dfhack.git --recursive

RUN cd /df/dfhack && git checkout dde589967ae9f5c59832c49011a6040eb3d797d3

RUN cd /df/dfhack/plugins && git clone https://github.com/white-rabbit-dfplex/dfplex.git --recursive

RUN cd /df/dfhack/plugins/dfplex && git checkout d9ff3f51537aa6d7d9c33bea42813559c91ea5d3

RUN cd /df/dfhack/plugins && wget https://gist.githubusercontent.com/kahveciderin/6c523e526bc8d193a9d51c4d90b2c2a2/raw/d37ab4968b4a5ea02eb5c6f67948529ad41b484f/CMakeList.txt.patch.txt

RUN cd /df/dfhack/plugins && patch CMakeLists.txt < CMakeList.txt.patch.txt && rm CMakeList.txt.patch.txt

RUN cd /df/dfhack/plugins && wget https://gist.githubusercontent.com/kahveciderin/0193b8c97d508a592a844f8808c6029c/raw/29c976ce70072df53e6e6310a5be22bb21011f01/dojobnow.cpp

RUN wget http://www.bay12games.com/dwarves/df_47_05_linux.tar.bz2

RUN tar -xvf df_47_05_linux.tar.bz2 df_linux/

RUN apt-get install g++ -y

RUN /bin/bash -c cd /df/dfhack/build && CXX=g++ cmake /df/dfhack -G Ninja -DCMAKE_BUILD_TYPE:string=Release -DCMAKE_INSTALL_PREFIX=/df/df_linux && ninja install -j$(nproc)

RUN apt-get install -y dos2unix screen

RUN cd /df/df_linux/data/init && wget https://gist.githubusercontent.com/kahveciderin/18944231b5df71a353d6980dec139bf5/raw/cc231e5c3b51ba2d6e1fa91838e142a70ca4751d/init.patch.txt && dos2unix init.txt && patch init.txt < init.patch.txt && rm init.patch.txt

RUN apt-get install libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libgtk2.0-0 libopenal1 libsndfile1 libncursesw5 -y

RUN echo -ne "enable dfplex\nenable buildingplan" > df_linux/dfhack.init

RUN echo -ne "#!/bin/bash\ncd /df/df_linux;while true;do linux64 /df/df_linux/dfhack;done" > start.sh && chmod +x start.sh

EXPOSE 1234

CMD ["/bin/bash", "/df/start.sh"]