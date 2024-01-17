 #!/bin/bash
 
# Developed by: Sebastian Maurice
# Date: 2023-05-22
########################### START ZOOKEEPER and KAFKA
 export KAFKA_HEAP_OPTS="-Xmx512M -Xms512M"
 export  userbasedir=`pwd`
 MYIP=$(ip route get 8.8.8.8 | awk '{ print $7; exit }')
 export MYIP
 CHIP2=${CHIP}
 chip=$(echo "$CHIP2" | tr '[:upper:]' '[:lower:]')
 mainos="linux"

 if [ "$chip" = "arm32" ]; then 
    export chip="arm"
    export mainos
 elif [ "$chip" = "mac" ]; then 
    export chip="amd64"
    export mainos="darwin"   
 else
    export chip 
    export mainos
 fi

service mariadb restart 2>/dev/null
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('raspberry');" 2>/dev/null
mysql -u root -e "GRANT ALL PRIVILEGES on *.* to 'root'@'localhost' IDENTIFIED BY 'raspberry';" 2>/dev/null
mysql -u root -e "FLUSH PRIVILEGES;" 2>/dev/null

# sudo mount -o remount,rw /partition/identifier $userbasedir

 kill -9 $(lsof -i:9092 -t) 2> /dev/null
 kill -9 $(lsof -i:2181 -t) 2> /dev/null
 
 sleep 2

 tmux new -d -s zookeeper
 tmux send-keys -t zookeeper 'cd $userbasedir/Kafka/kafka_2.13-3.0.0/bin' ENTER
 tmux send-keys -t zookeeper './zookeeper-server-start.sh $userbasedir/Kafka/kafka_2.13-3.0.0/config/zookeeper.properties' ENTER

 sleep 4

 tmux new -d -s kafka 
 tmux send-keys -t kafka 'cd $userbasedir/Kafka/kafka_2.13-3.0.0/bin' ENTER
 tmux send-keys -t kafka './kafka-server-start.sh $userbasedir/Kafka/kafka_2.13-3.0.0/config/server.properties' ENTER

sleep 10
 ########################## SETUP VIPER/HPDE/VIPERVIZ Binaries For Transactional Machine Learning 
 
# STEP 1: Produce Data to Kafka
# STEP 1a: RUN VIPER Binary
  
 tmux new -d -s produce-iot-data-viper-8000 
 tmux send-keys -t produce-iot-data-viper-8000 'cd $userbasedir/Viper-produce' ENTER
 tmux send-keys -t produce-iot-data-viper-8000 '$userbasedir/Viper-produce/viper-$mainos-$chip' ENTER
 
# STEP 2: Preprocess Data from Kafka
# STEP 2a: RUN VIPER Binary
 tmux new -d -s preprocess-data-viper-8001
 tmux send-keys -t preprocess-data-viper-8001 'cd $userbasedir/Viper-preprocess' ENTER
 tmux send-keys -t preprocess-data-viper-8001 '$userbasedir/Viper-preprocess/viper-$mainos-$chip' ENTER

 #tmux new -d -s tml-data-viper
 #tmux send-keys -t tml-data-viper 'cd $userbasedir/Viper-tml' ENTER 
 #tmux send-keys -t tml-data-viper '$userbasedir/Viper-tml/viper-$mainos-$chip' ENTER

 #tmux new -d -s predict-data-viper
 #tmux send-keys -t predict-data-viper 'cd $userbasedir/Viper-predict' ENTER 
 #tmux send-keys -t predict-data-viper '$userbasedir/Viper-predict/viper-$mainos-$chip' ENTER

 #tmux new -d -s ml-predict-data-hpde
 #tmux send-keys -t ml-predict-data-hpde 'cd $userbasedir/Hpde' ENTER 
 #tmux send-keys -t ml-predict-data-hpde '$userbasedir/Hpde/hpde-$mainos-$chip' ENTER

sleep 7

# STEP 2b: RUN PYTHON Script  
 tmux new -d -s produce-iot-data-python-8000 
 tmux send-keys -t produce-iot-data-python-8000 'cd $userbasedir/IotSolution' ENTER
 tmux send-keys -t produce-iot-data-python-8000 'python $userbasedir/IotSolution/produce-iot-customdata.py' ENTER

 tmux new -d -s preprocess-data-python-8001
 tmux send-keys -t preprocess-data-python-8001 'cd $userbasedir/IotSolution' ENTER 
 tmux send-keys -t preprocess-data-python-8001 'python $userbasedir/IotSolution/preprocess-iot-monitor-customdata.py' ENTER
  

 #tmux new -d -s tml-data-python
 #tmux send-keys -t tml-data-python 'cd $userbasedir/IotSolution' ENTER
 #tmux send-keys -t tml-data-python 'python $userbasedir/IotSolution/iot-ml-training_topicid_logistics.py' ENTER

#tmux new -d -s predict-data-python
# tmux send-keys -t predict-data-python 'cd $userbasedir/IotSolution' ENTER
# tmux send-keys -t predict-data-python 'python $userbasedir/IotSolution/iot-ml-predictions_topicid_logistics.py' ENTER


# STEP 5: START Visualization Viperviz 
 tmux new -d -s visualization-viperviz-9005 
 tmux send-keys -t visualization-viperviz-9005 'cd $userbasedir/Viperviz' ENTER
 tmux send-keys -t visualization-viperviz-9005 '$userbasedir/Viperviz/viperviz-$mainos-$chip 0.0.0.0 9005' ENTER
 
