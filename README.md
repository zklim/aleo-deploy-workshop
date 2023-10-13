# Aleo Deployment Demo

In this repository we will go through the steps to deploy your own Leo program on the Aleo Network.

## Prerequisites

Make sure you have the following software installed on your local machine:

### Software Installation

1.  [Install Git](https://git-scm.com/downloads)
2.  [Install Rust](https://www.rust-lang.org/tools/install)
3.  [Install Leo](https://developer.aleo.org/leo/installation)
4.  [Install snarkos](https://github.com/AleoHQ/snarkOS)
5.  [Install Leo Wallet](https://leo.app/)
6.  [Install VSCode](https://code.visualstudio.com/download)

### FAQ

If you run into issues while installing the above software, or following the workshop, please see the [FAQ](./FAQ.md)

### Create a Leo Wallet

You will need a Leo Wallet to deploy your program. You have two options to setup a wallet

#### The CLI

You can create a wallet using the Leo CLI by running the following command

`leo account new`

Be sure to save the Address, View and Private Keys of this wallet, you will need them later.

#### Chrome Extension

Ensure you installed [Leo Wallet](leo.app) and follow the setup process to create a new wallet.

### Get Testnet Tokens

You can get testnet tokens by using the [Aleo Faucet](https://faucet.aleo.org/).

If you are using the Leo Wallet Chrome Extension, you can also get testnet tokens by clicking on the wallet and then clicking on the `Faucet` button. Scan the QR code and send the generated text message to recieve testnet tokens.

## Deployment Demo

### Step 1: Initalize a Leo Project

Run the following command to initalize a leo project.
In Leo, programs must be unique, so make sure to use a unique name.

macOS & Unix based systems

`leo new token_$RANDOM`

Windows (choose a random string of alphanumeric characters)

`leo new token_(RANDOM_CHARACTERS_HERE)`

The result will be a new folder `project_name` with the following structure:

```
.
├── README.md
├── build
│   ├── main.aleo
│   └── program.json
├── inputs
│   └── deploy_workshop.in
├── program.json
└── src
    └── main.leo
```

### Step 2: Write your program

Write your code in the `src/main.leo` file. For this demo we will be using the following code that implements a basic token.

```
// Replace <project_name> with the name of your project.
program <project_name>.aleo {
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
```

### Define Inputs

In the `./inputs/project_name.in` file, we need to define the inputs for our program. For this demo we will be using the following inputs:

```
// The program input for deploy_workshop/src/main.leo
[mint]
balance: u32 = 100u32;

[transfer]
receiver: address = aleo1yn6halw6astkc8jsl88sukelef3e8xrawugfjtx7kjcuuxdm6spsdtc249;
amount: u32 = 10u32;
input: Token = Token {
  owner: aleo102nryeeun6da4atqggu0q9aj5cqem7tpjzvce4nc88yzu29n8sgs9qelp7,
  balance: 100u32,
  _nonce: 661901642905281065575358583071347542160248627750537954509114007526888699661group
};
```

### Build & Test our Program

Let's make sure that our program is working by running the following commands:

1. Can we mint tokens? `leo run mint`
   You should see the following output:

```
{
  owner: aleo102nryeeun6da4atqggu0q9aj5cqem7tpjzvce4nc88yzu29n8sgs9qelp7.private,
  balance: 100u32.private,
  _nonce: 292936196563333932009136915121914006898609101920119023221288671394356999564group.public
}
```

Copy the output record from the mint transition and paste it into the `./inputs/project_name.in` file under the `[transfer]` section. Be sure to remove the `.private` and `.public` suffixes.

2. Can we transfer tokens? `leo run transfer`

```craigjohnson@home deploy_workshop % leo run transfer
       Leo ✅ Compiled 'main.leo' into Aleo instructions

⛓  Constraints

 •  'deploy_workshop.aleo/transfer' - 4,075 constraints (called 1 time)

➡️  Outputs

 • {
  owner: aleo1yn6halw6astkc8jsl88sukelef3e8xrawugfjtx7kjcuuxdm6spsdtc249.private,
  balance: 10u32.private,
  _nonce: 3050046340461200467640466967043652446168052649619713936697821365575779437863group.public
}
 • {
  owner: aleo102nryeeun6da4atqggu0q9aj5cqem7tpjzvce4nc88yzu29n8sgs9qelp7.private,
  balance: 90u32.private,
  _nonce: 7955845234401838954345597221810328519950488237684582098690500295625246536712group.public
}
```

You can see here, one account now has 90 tokens and the other has 10, meaning we succesfully transfered 10 tokens.

### Step 3. Convert public fees to private fees

Two ways of doing this:
1. [aleo.tools](https://aleo.tools/transfer)

2. Using snarkos
   - `snarkos developer execute --private-key "${PRIVATE_KEY}" --query "https://api.explorer.aleo.org/v1" "credits.aleo" "transfer_public_to_private" "<ADDRESS_TO_SEND>" "10000000u64" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast"`

### Step 4. Create our Deployment Script

We need a few environment variables set to deploy our program. We can create a script to set these variables for us.

Create a new file named `deploy.sh` in the project directory and copy the following into the file

```

WALLETADDRESS=""
PRIVATEKEY=""

APPNAME="<project_name>"

RECORD="{
RECORD PLAINTEXT HERE
}"

cd .. && snarkos developer deploy "${APPNAME}.aleo" --private-key "${PRIVATEKEY}" --query "https://vm.aleo.org/api" --path "./${APPNAME}/build/" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast" --fee 1000000 --record "${RECORD}"``

```

Fill out the variables with the appropriate values and save the file

### Step 5. Execute the Script to Deploy our Program

Run the deploy script

`bash ./deploy.sh`

You see output like this if successful
![](./deployment_success.png)

Don't forget to save your work!
