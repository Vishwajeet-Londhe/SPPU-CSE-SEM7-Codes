// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract ProductInventory {
    struct Product {
        uint256 id;
        string name;
        uint256 stock;
    }

    mapping(uint256 => Product) private products;

    event ProductReceived(uint256 id, uint256 quantity);
    event ProductSold(uint256 id, uint256 quantity);

    function addProduct(uint256 id, string memory name, uint256 stock) public {
        require(products[id].id == 0, "Product exists");
        products[id] = Product(id, name, stock);
    }

    function receiveProduct(uint256 id, uint256 quantity) public {
        require(products[id].id != 0, "Product not found");
        products[id].stock += quantity;
        emit ProductReceived(id, quantity);
    }

    function saleProduct(uint256 id, uint256 quantity) public {
        require(products[id].id != 0, "Product not found");
        require(products[id].stock >= quantity, "Insufficient stock");
        products[id].stock -= quantity;
        emit ProductSold(id, quantity);
    }

    function displayStock(uint256 id) public view returns (uint256) {
        require(products[id].id != 0, "Product not found");
        return products[id].stock;
    }
}
