pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
    address owner = 0x441e4635D9D6e53027d6a817F2Aa81fe37F39988;
    constructor() ERC20("Gold", "GLD") {
        _mint(owner, 1000 * 10 ** 18);
    }
}
