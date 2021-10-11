// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./extensions/energy.sol";


enum adjustmentType { None, Lighten, Darken, SmartLightDark }
enum colorType { Unset, Primary, Secondary, Accent0, Accent1, Accent2 }

struct Pixel {
  uint16 x;
  uint16 y;
  colorType color;
  adjustmentType adjustment;
  uint8 adjAmount;
}

contract CommunityCanvas is
    AccessControl 
{
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  
  event Painted(uint16 x, uint16 y, colorType color, adjustmentType adjustment, uint8 adjAmount, address painter);
  
  Pixel[100][100] public Pixels;

  uint256 private _paintPrice = 2 ether;
  bool private _paintingEnabled = true;
  bool private _locked = false;
  
  uint256 private _uniqueContributors = 0;
  mapping(address => uint256) private _contributors; // address and paint count

  // VechainThor
  Energy constant energy = Energy(0x0000000000000000000000000000456E65726779);

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADMIN_ROLE, msg.sender);
  }

  // ----------------------------------------------------------------------------
  // Start:  Public Read
  // ----------------------------------------------------------------------------  
  function getUniqueContributors() public view returns (uint256) {
    return _uniqueContributors;
  }

  function getPaintCount(address painter) public view returns (uint256) {
    return _contributors[painter];
  }
  // ----------------------------------------------------------------------------
  // End:  Public Read
  // ----------------------------------------------------------------------------

  // ----------------------------------------------------------------------------
  // Start:  Paint
  // ----------------------------------------------------------------------------
  function paint(
      uint16 x,
      uint16 y,
      colorType color,
      adjustmentType adjustment,
      uint8 adjAmount
  ) public payable { 
    require(_paintingEnabled, "Painting is not enabled");
    require(msg.value == _paintPrice, "The VET sent is not correct.");
    
    
    if(_contributors[msg.sender] == 0) {
      // only count unique contributors
      _uniqueContributors += 1;
    }
    _contributors[msg.sender] += 1;

    Pixel memory pixel = Pixel(x, y, color, adjustment, adjAmount);
    Pixels[x][y] = pixel;
    // Broadcast the paint event
    emit Painted(x, y, color, adjustment, adjAmount, msg.sender);
  }
  // ----------------------------------------------------------------------------
  // End:  Paint
  // ----------------------------------------------------------------------------
  
  // ----------------------------------------------------------------------------
  // Start: ADMIN_ROLE
  // ----------------------------------------------------------------------------
  function disablePaint() public onlyRole(ADMIN_ROLE) {
    _paintingEnabled = false;
  }

  function enablePaint() public onlyRole(ADMIN_ROLE) {
    require(!_locked, "Cannot enable painting once locked.");
    _paintingEnabled = true;
  }

  function lock() public onlyRole(ADMIN_ROLE) {
    _paintingEnabled = false;
    _locked = true;
  }

  function setPaintPrice(uint256 price) public onlyRole(ADMIN_ROLE) {
    _paintPrice = price;
  }

  function withdraw() public onlyRole(ADMIN_ROLE) {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }

  function withdrawVtho(uint256 amount) public onlyRole(ADMIN_ROLE) {
    energy.transfer(msg.sender, amount);
  }
  // ----------------------------------------------------------------------------
  // End:  ADMIN_ROLE
  // ----------------------------------------------------------------------------
}