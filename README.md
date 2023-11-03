# Airlines ERC20 Token

### Task - Airlines Token

~ A smart contract for Airplane ticket management. You can develop it in whatever smart contract development framework you want, Remix IDE is the preferable one.

This smart contract will need to have admin functionalities. Oftentimes they are managed by multisig wallets. You should be able to create a mechanism where only the admin wallet can execute certain actions. For the ownership transfer, the admin should initiate the transferOwnership function, and the new admin should accept the ownership transfer.

Admin should be able to register a new Airplane. Each Airplane has info about the number of seats in the economy & first class, and details about the previous flights. Admin should be able to put the airplane on hold due to mechanic issues. While off, the contract should prevent the admin from scheduling flights for this airplane.

Admin should be able to announce the new flight. Each flight should have information about the airplane, final destination, departure time, number of seats available and ticket prizes. Contract should prevent selling tickets for the same seat twice.

The User should be able to purchase up to 4 tickets for the desired flight. The crypto earned from selling, MVPW Airlines should hold in Treassury. The User can cancel ticket purchasing. If cancellation happened:

- Less than 24 hours before the flight - No refund
- Between 24 & 48 hours before the flight - 80% refund
- More than 48 hours before the flight - Full refund

Purchasing can only be done in the MPVW Airlines ERC20 token available at address 0x71bDd3e52B3E4C154cF14f380719152fd00362E7.

#### Task Goals:

Implement all functionalities using the Checks-Effects-Interactions pattern

Deploy smart contract to Goerli testnet

Verify it on Etherscan

Use NatSpec

Follow function & variables ordering rules

Emit events

Use OpenZeppelin if applicable

### Learning Materials

Solidity is an Object-Oriented Structural Programming Language for writing smart contracts on EVM-compatible blockchains like Ethereum or Polygon. To compile the Solidity codebase into the EVM bytecode and ABI, one needs to use the Solidity compiler, “solc”, which current major version is ^0.8.

There are two types of functions, ones that read data from the blockchain, and ones that mutate the blockchain’s state. The first ones are gas free and have a “view” modifier. The second ones initiate transactions which the initiator needs to pay, and that’s why we tend to optimize our contracts as much as possible.

Programming smart contracts is more like programming hardware than programming software, because once deployed, contracts are immutable. That’s why security is our number one priority.

Official documentation: https://docs.soliditylang.org/en/latest/

Use Check-Effects-Interactions pattern.

Follow NatSpec when documenting your contract.

Follow this contract structure: https://gist.github.com/andrejrakic/2a61faa2157efff1684d212b2c754eb8

Roadmap for learning Solidity: https://solidity-by-example.org/

Try to use the OpenZeppelin library if applicable since it is battle tested and considered an industry standard.
