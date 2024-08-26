import "@stdlib/deploy";

message(0x7362d09c) TokenNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    forwardPayload: Slice as remaining;
}


message(0xf8a7ea5) TokenTransfer {
     queryId: Int as uint64; // should be 0
     amount: Int as coins; // should be amount of jettons to send
     destination: Address; // should be user address / TokenNotification.from
     responseDestination: Address?; // should be myAddress()
     customPayload: Cell?; // should be null    
     forwardTonAmount: Int as coins; // should be ton("0.01")
     forwardPayload: Slice as remaining; // should be emptySlice()
}

const decimal: Int = 1000000000;

contract TactDex with Deployable {
    owner: Address;
    aAmount: Int;
    bAmount: Int;
    jettonAddressA: Address;
    jettonAddressB: Address;

    init(admin: Address, newJettonAddressA: Address, newJettonAddressB: Address) {
    self.owner = admin;
    self.aAmount = 0;
    self.bAmount = 0;
    self.jettonAddressA = newJettonAddressA;
    self.jettonAddressB = newJettonAddressB;
  }

  receive(msg: TokenNotification) {
    let ctx_sender: Address = sender();
    //received jetton B
    if(ctx_sender == self.jettonAddressB) {
        // if the sender is the owner , then we add the jetton to the pool
        if ( msg.from == self.owner) {
            self.bAmount = self.bAmount + msg.amount;
            return;
        }
        // if the sender is not the owner, then we calculate the amount of jetton A to send
        let aAmountToSend: Int = (self.aAmount * decimal / self.bAmount) * msg.amount / decimal;
        // if the amount of jetton A to send is greater than the amount of jetton A in the pool, then we send jetton B back 
        if ( aAmountToSend > self.aAmount) {
            send(SendParameters{
                to: self.jettonAddressB,
                value: 0,
                mode: SendRemainingValue,
                body: TokenTransfer{
                    queryId: 0,
                    amount: msg.amount, 
                    destination: msg.from,
                    responseDestination: myAddress(),
                    customPayload: null,
                    forwardTonAmount: ton("0.01"),
                    forwardPayload: emptySlice()
                }.toCell()
            });
            return;
        }
        // if the amount of jetton A to send is less than the amount of jetton A in the pool then we send the jetton A and update the  
        /*self.bAmount = self.bAmount + msg.amount;
        self.aAmount = self.aAmount - aAmountToSend;*/
        send(SendParameters{
            to: self.jettonAddressA,
            value: 0,
            mode: SendRemainingValue,
            body: TokenTransfer{
                queryId: 0,
                amount: aAmountToSend,
                destination: msg.from,
                responseDestination: myAddress(),
                customPayload: null,
                forwardTonAmount: ton("0.01"),
                forwardPayload: emptySlice()
            }.toCell()
        });
        return;
    // received jetton A
    }else if ( ctx_sender == self.jettonAddressA) {
        //if the sender is the owner, then we add the jetton to the pool
        if (msg.from == self.owner) {
            self.aAmount = self.aAmount + msg.amount;
            return;
        }
        // if the sender is not the owner, then we calculate the amount of jetton B to send
        let bAmountToSend: Int = (self.bAmount * decimal / self.aAmount) * msg.amount /decimal;
        // if the amount of jetton B to send is greater than the amount of jetton B in the pool, then we send jetton A back
        if ( bAmountToSend > self.bAmount) {
            send(SendParameters{
                to: self.jettonAddressA,
                value: 0,
                mode: SendRemainingValue,
                body: TokenTransfer{
                    queryId: 0,
                    amount: msg.amount,
                    destination: msg.from,
                    responseDestination: myAddress(),
                    customPayload: null,
                    forwardTonAmount: ton("0.01"),
                    forwardPayload: emptySlice()
                }.toCell()
            });
            return;
        }
    //if the amount of jetton B to send is less than the amount of jetton B in the pool, then we send the jetton B and update the 
    self.aAmount = self.aAmount + msg.amount;
    self.bAmount = self.bAmount - bAmountToSend;
    send(SendParameters{
        to: self.jettonAddressB,
        value: 0,
        mode: SendRemainingValue,
        body: TokenTransfer{
            queryId: 0,
            amount: bAmountToSend,
            destination: msg.from,
            responseDestination: myAddress(),
            customPayload: null,
            forwardTonAmount: ton("0.01"),
            forwardPayload: emptySlice()
        }.toCell()
    });
    return;
  }
  //receive a different jetton ( neither A nor B), throw an error 
    throw(0xf);
}
  
  get fun balance(jetton: Address): Int {
    // if the jetton is A, then we retur the amount of A
    if(jetton == self.jettonAddressA) {
        return self.aAmount;
    }
    //if the jetton is B, then we return the amount of B
    return self.bAmount;
  }

  get fun price(jetton: Address): Int {
    // if the jetton is A, then we return the price of A
    if(jetton == self.jettonAddressA) {
        return self.bAmount * decimal / self.aAmount;
    }
    // if the jetton is B, then we return the price of B
    return self.aAmount * decimal /self.bAmount;
  }
}
