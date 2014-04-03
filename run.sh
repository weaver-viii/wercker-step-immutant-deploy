IMMUTANT_SCRIPT=setup-immutant.sh

# Copy the script to the servers
scp -i $PRIVATEKEY_PATH -o "StrictHostKeyChecking no" -P 2222 $WERCKER_STEP_ROOT/$IMMUTANT_SCRIPT deploy@localhost:$IMMUTANT_SCRIPT
scp -i $PRIVATEKEY_PATH -o "StrictHostKeyChecking no" -P 2223 $WERCKER_STEP_ROOT/$IMMUTANT_SCRIPT deploy@localhost:$IMMUTANT_SCRIPT

# Run the script on the servers
ssh -i $PRIVATEKEY_PATH -o "StrictHostKeyChecking no" -p 2222 deploy@localhost "$IMMUTANT_SCRIPT"
ssh -i $PRIVATEKEY_PATH -o "StrictHostKeyChecking no" -p 2223 deploy@localhost "$IMMUTANT_SCRIPT"
