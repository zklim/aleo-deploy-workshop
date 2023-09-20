// Replace <project_name> with the name of your project.
program deploy_workshop.aleo {
    // Define a token struct with an owner and balance
    record Token {
        owner: address,
        balance: u32,
    }

    // Define a mint transition that takes a balance and returns a token
    transition mint(amount: u32) -> Token {
        return Token {
            owner: self.caller,
            balance: amount,
        };
    }

    // Define a transfer transition that takes a receiver, amount and token and returns two tokens
    transition transfer(receiver: address, transfer_amount: u32, input: Token) -> (Token, Token) {
        let sender_balance: u32 = input.balance - transfer_amount;
        let recipient: Token = Token {
            owner: receiver,
            balance: transfer_amount,
        };

        let sender: Token  = Token {
            owner: self.caller,
            balance: sender_balance
        };

        return (recipient, sender);
    }
}