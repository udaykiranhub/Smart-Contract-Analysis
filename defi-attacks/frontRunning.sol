=> Front-running occurs when an attacker sees a pending transaction and submits a similar one 
with a higher gas fee to execute first.

--->
.User submits a transaction to buy tokens at a certain price.

.Attacker sees this in the mempool.

.Attacker submits a buy order with a higher gas fee.

.Attacker gets the tokens first and sells them for a profit.

->Mitigation
.Use commit-reveal schemes.

.Implement maximum slippage settings.

U.se private transaction relays (Flashbots).