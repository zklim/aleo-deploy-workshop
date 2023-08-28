# Aleo Deployment Demo

In this repository we will go through the steps to deploy your own Leo program on to the Aleo Network.

## Prerequisites

Make sure you have the following software installed on your local machine:

### Software Installation

1.  [Install Git](https://git-scm.com/downloads)
2.  [Install Rust](https://www.rust-lang.org/tools/install)
3.  [Install Leo](https://developer.aleo.org/leo/installation)
4.  [Install snarkos](https://developer.aleo.org/testnet/getting_started/installation/)
5.  [Install Leo Wallet](https://leo.app/)

### Create a Leo Wallet

You will need a Leo Wallet to deploy your program. You can create a wallet by running the following command:

`leo account new`

Be sure to save the Address, View and Private Keys of this wallet, you will need them later.

### Get Testnet Tokens

If you are participating in a live workshop, you will be given a wallet and testnet tokens to use.

If you are not participating in a live workshop, or you prefer to do this part yourself, you can get testnet tokens by using the [Aleo Faucet](https://faucet.aleo.org/).

## Demo

### Step 1: Initalize a Leo Project

Run the following command to initalize a leo project, be sure to replace `<project_name>` with the name of your project.
In Leo, programs must be unique, so make sure to use a unique name.

`leo new <project_name>`

### Step 2: Write your program

Write your code in the main.leo file. For this demo we will be using the following code:

```
// Replace <project_name> with the name of your project.
program <project_name>.aleo {
    record Token {
        owner: address,
        balance: u32,
    }

    transition mint(balance: u32) -> Token {
        return Token {
            owner: self.caller,
            balance: balance,
        };
    }

    transition transfer(receiver: address, amount: u32, input: Token) -> (Token, Token) {
        let balance: u32 = input.balance - amount;
        let recipient: Token = Token {
            owner: receiver,
            balance: amount,
        };

        let sender: Token  = Token {
            owner: self.caller,
            balance
        };

        return (recipient, sender);
    }
}
```

### Step 3. Getting our Record Plaintext

We need to retrieve our Wallet's current record plaintext to deploy our program. I prefer to use the Leo Wallet to do this

1. Open the Leo Wallet
2. Click on the Wallet you created in the Prerequisites
3. Click on the Activities tab and click into the most recent transaction, this opens a new window in a block explorer
4. You should see this page
   ![](./transitions.png)
5. Click on the first transition ID, this will open a new page
6. Connect your wallet, scroll down and retrieve your record data, it should be highlighted in green text, save this text for the next step

### Step 4. Create our Deployment Script

We need a few environment variables set to deploy our program. We can create a script to set these variables for us.
Here's an example

Create a new file named `deploy.sh` in the project directory and copy the following into the file

````
WALLETADDRESS=""
PRIVATEKEY=""

APPNAME="<project_name>"
PATHTOAPP=$(realpath -q $APPNAME)


RECORD="{
    RECORD PLAINTEXT HERE
}"

cd .. && snarkos developer deploy "${APPNAME}.aleo" --private-key "${PRIVATEKEY}" --query "https://vm.aleo.org/api" --path "./${APPNAME}/build/" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast" --fee 1000000 --record "${RECORD}"```
````

### Step 5. Execute the Script to Deploy our Program

Run the deploy script

`bash ./deploy.sh`

You see output like this if successful
![](./deployment_success.png)
