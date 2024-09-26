echo "say Server will shut down in 15 seconds!" > fifo-input-file
sleep 15
echo "stop" > fifo-input-file
