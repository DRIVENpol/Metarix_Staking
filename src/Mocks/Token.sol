// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MocksERC20 is ERC20, Ownable {
    constructor() ERC20("MyToken", "MT") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }

    function mintToStaking(address stakinSc) public {
        _mint(stakinSc, 100_000 * 10 ** 18);
    }
}