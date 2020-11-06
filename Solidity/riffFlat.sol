pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


library AddressHelper {
    function recoverAddress(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public pure
        returns (address) {
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        uint8 vv = v;
        if (vv < 27) {
            vv += 27;
        }

        // If the version is correct return the signer address
        if (vv != 27 && vv != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, vv, r, s);
        }

    }

    function char(byte b) public pure returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }

    function getHashedPublicKey(
        bytes32 _xPoint,
        bytes32 _yPoint)
        pure public
        returns(
            bytes20 hashedPubKey)
    {
        byte startingByte = 0x04;
        return ripemd160(abi.encodePacked(sha256(abi.encodePacked(startingByte, _xPoint, _yPoint))));
    }

    function fromHexChar(uint c) public pure returns (uint) {
        if (c >= uint(byte('0')) && c <= uint(byte('9'))) {
            return c - uint(byte('0'));
        }

        if (c >= uint(byte('a')) && c <= uint(byte('f'))) {
            return 10 + c - uint(byte('a'));
        }

        if (c >= uint(byte('A')) && c <= uint(byte('F'))) {
            return 10 + c - uint(byte('A'));
        }

        // Reaching this point means the ordinal is not for a hex char.
        revert();
    }

    function fromAsciiString(string s) public pure returns(address) {
        bytes memory ss = bytes(s);

        // it should have 40 or 42 characters
        if (ss.length != 40 && ss.length != 42) revert();

        uint r = 0;
        uint offset = 0;

        if (ss.length == 42) {
            offset = 2;

            if (ss[0] != byte('0')) revert();
            if (ss[1] != byte('x') && ss[1] != byte('X')) revert();
        }

        uint i;
        uint x;
        uint v;

        // loads first 32 bytes from array,
        // skipping array length (32 bytes to skip)
        // offset == 0x20
        assembly { v := mload(add(0x20, ss)) }

        // converts the first 32 bytes, adding to result
        for (i = offset; i < 32; ++i) {
            assembly { x := byte(i, v) }
            r = r * 16 + fromHexChar(x);
        }

        // loads second 32 bytes from array,
        // skipping array length (32 bytes to skip)
        // and first 32 bytes
        // offset == 0x40
        assembly { v := mload(add(0x40, ss)) }

        // converts the last 8 bytes, adding to result
        for (i = 0; i < 8 + offset; ++i) {
            assembly { x := byte(i, v) }
            r = r * 16 + fromHexChar(x);
        }

        return address(r);
    }
}






/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


library AddressLinker   {
    using SafeMath for uint256;
    using SafeMath for uint;

    uint constant BITCOIN  = 0;
    uint constant ETHEREUM = 1;

    function acceptLinkedRskAddress(
        address buyerAddress, uint chainId,
        string redeemAddressAsString, uint8 sig_v,
        bytes32 sig_r, bytes32 sig_s) public pure returns (bool) {

        // Verify signatures
        bytes32 hash;

        if (chainId == BITCOIN) {
            hash = sha256(abi.encodePacked(sha256(abi.encodePacked("\x18Bitcoin Signed Message:\n\x2a", redeemAddressAsString))));
        } else {
            hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n42", redeemAddressAsString));
        }

        address recoveredAddress = AddressHelper.recoverAddress(hash, sig_v, sig_r, sig_s);

        return recoveredAddress == address(buyerAddress);
    }

    function acceptDelegate(
        address buyerAddress, uint chainId,
        uint8 sig_v,
        bytes32 sig_r, bytes32 sig_s) public pure returns (bool) {

        // Verify signatures
        bytes32 hash;

        if (chainId==BITCOIN) {
            hash = sha256(abi.encodePacked(sha256(abi.encodePacked("\x18Bitcoin Signed Message:\n\x0a","DELEGATION"))));
        } else {
            hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n10","DELEGATION"));
        }

        address recoveredAddress = AddressHelper.recoverAddress(hash,sig_v,sig_r,sig_s);

        return recoveredAddress == address(buyerAddress);
    }
}


 /*
 * Contract interface for receivers of tokens that
 * comply with ERC-677.
 * See https://github.com/ethereum/EIPs/issues/677 for details.
 */
contract ERC677TransferReceiver {
    function tokenFallback(address from, uint256 amount, bytes data) public returns (bool);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}











/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}






/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}






contract RIFToken is DetailedERC20, Ownable, StandardToken {
    /**
     * Transfer event as described in ERC-677
     * See https://github.com/ethereum/EIPs/issues/677 for details
     */
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    mapping(address => uint) public minimumLeftFromSale;

    // is the account of the original contributor
    mapping(address => bool) public isInitialContributor;

    // redeemed to same account or to another account
    mapping(address => bool) public isRedeemed;

    // original or redeemed contributor addresses
    mapping (address => bool) public isOriginalOrRedeemedContributor;

    // redirect:
    // returns new address old address is now mapped
    mapping(address => address) public redirect;

    bool public enableManagerContract;
    address public authorizedManagerContract;

    uint public distributionTime;

    uint256 constant REDEEM_DEADLINE = 365 days;
    address constant ZERO_ADDRESS = address(0);

    // The RIF token has minimum ownership permissions until ownership is manually withdrawn by
    // releaseOwnership()

    constructor() DetailedERC20("RIF","RIF",18) public {
        // There will only ever be 1 billion tokens. Each tokens has 18 decimal digits.
        // Therefore, 1 billion = 1,000,000,000 = 10**9 followed by 18 more zeroes = 10**18
        // Total => 10**27 RIFIs.
        totalSupply_ = 10**27;
        balances[address(this)] = totalSupply_;
        enableManagerContract = false;
        authorizedManagerContract = ZERO_ADDRESS;
        distributionTime = 0;
    }

    function getMinimumLeftFromSale(address a) public view returns(uint) {
        address dest = getRedirectedAddress(a);
        return minimumLeftFromSale[dest];
    }

    function disableManagerContract() public onlyAuthorizedManagerContract {
        enableManagerContract = false;
    }

    function closeTokenDistribution(uint _distributionTime) public onlyAuthorizedManagerContract {
        require(distributionTime == 0);
        distributionTime = _distributionTime;
    }

    function setAuthorizedManagerContract(address authorized) public onlyOwner {
        require(authorizedManagerContract == ZERO_ADDRESS);
        authorizedManagerContract = authorized;
        enableManagerContract = true;
        transferAll(this, authorized);
    }

    modifier onlyAuthorizedManagerContract() {
        require(msg.sender==authorizedManagerContract);
        require(enableManagerContract);
        _;
    }

    modifier onlyWhileInDistribution() {
        require(distributionTime == 0);
        _;
    }

    modifier onlyAfterDistribution() {
        require(distributionTime > 0 && now >= distributionTime);
        _;
    }

    modifier onlyIfAddressUsable(address sender) {
        require(!isInitialContributor[sender] || isRedeemed[sender]);
        _;
    }

    // Important: this is an internal function. It doesn't verify transfer rights.
    function transferAll(address _from, address _to) internal returns (bool) {
        require(_to != ZERO_ADDRESS);

        uint256 _value;

        _value = balances[_from];
        balances[_from] = 0;
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function transferToShareholder(address wallet, uint amount) public onlyWhileInDistribution onlyAuthorizedManagerContract {
        bool result = super.transfer(wallet, amount);

        if (!result) revert();
    }

    // TokenManager is the owner of the tokens to the pre-sale contributors and will distribute them
    // also TokenManager is the owner of the bonuses.
    function transferToContributor(address contributor, uint256 amount) public onlyWhileInDistribution onlyAuthorizedManagerContract {
        if (!validAddress(contributor)) return;

        super.transfer(contributor, amount);

        minimumLeftFromSale[contributor] += amount; //sets the contributor as an ITA special address

        isInitialContributor[contributor] = true;
        isOriginalOrRedeemedContributor[contributor] = true;
    }

    // If this transfer fails, there will be a problem because other bonus won't be able to be paid.
    function transferBonus(address _to, uint256 _value) public onlyAuthorizedManagerContract returns (bool) {
        if (!isInitialContributor[_to]) return false;

        address finalAddress = getRedirectedAddress(_to);

        return super.transfer(finalAddress, _value);
    }

    function delegate(address from, address to) public onlyAuthorizedManagerContract returns (bool) {
        if (!isInitialContributor[from] || isRedeemed[from]) {
            return false;
        }

        if (!transferAll(from, to)) {
            return false;
        }

        // mark as redirected and redeemed, for informational purposes
        redirect[from] = to;
        isRedeemed[from] = true;

        return true;
    }

    function redeemIsAllowed() public view returns (bool) {
        return  distributionTime > 0 &&
                now >= distributionTime &&
                now <= distributionTime + REDEEM_DEADLINE;
    }

    function redeemToSameAddress() public returns (bool) {
        require(redeemIsAllowed());

        // Only an original contributor can be redeemed
        require(isInitialContributor[msg.sender]);

        isRedeemed[msg.sender] = true;

        return true;
    }

    // Important: the user should not use the same contributorAddress for two different chains.
    function redeem(
        address contributorAddress, uint chainId,
        string redeemAddressAsString, uint8 sig_v,
        bytes32 sig_r, bytes32 sig_s) public returns (bool) {

        require(redeemIsAllowed());

        // Only an original contributor can be redeemed
        require(isInitialContributor[contributorAddress]);

        // Avoid redeeming an already redeemed address
        require(!isRedeemed[contributorAddress]);

        address redeemAddress = AddressHelper.fromAsciiString(redeemAddressAsString);

        // Avoid reusing a contributor address
        require(!isOriginalOrRedeemedContributor[redeemAddress]);

        require(AddressLinker.acceptLinkedRskAddress(contributorAddress, chainId,
            redeemAddressAsString, sig_v, sig_r, sig_s));

        // Now we must move the funds from the old address to the new address
        minimumLeftFromSale[redeemAddress] = minimumLeftFromSale[contributorAddress];
        minimumLeftFromSale[contributorAddress] = 0;

        // Mark as redirected and redeemed
        redirect[contributorAddress] = redeemAddress;
        isRedeemed[contributorAddress] = true;
        isOriginalOrRedeemedContributor[redeemAddress] = true;

        // Once the contributorAddress has moved the funds to the new RSK address, what to do with the old address?
        // Users should not receive RIFs in the old address from other users. If they do, they may not be able to access
        // those RIFs.
        return transferAll(contributorAddress, redeemAddress);
    }

    function contingentRedeem(
        address contributorAddress,
        uint chainId,
        address redeemAddress, uint8 sig_v,
        bytes32 sig_r, bytes32 sig_s) public onlyOwner returns (bool) {

        require(redeemIsAllowed());

        // Only an original contributor can be redeemed
        require(isInitialContributor[contributorAddress]);

        // Avoid redeeming an already redeemed address
        require(!isRedeemed[contributorAddress]);

        // Avoid reusing a contributor address
        require(!isOriginalOrRedeemedContributor[redeemAddress]);

        if (!AddressLinker.acceptDelegate(contributorAddress, chainId, sig_v, sig_r, sig_s)) revert();

        // Now we must move the funds from the old address to the new address
        minimumLeftFromSale[redeemAddress] = minimumLeftFromSale[contributorAddress];
        minimumLeftFromSale[contributorAddress] = 0;

        // Mark as redirected and redeemed
        redirect[contributorAddress] = redeemAddress;
        isRedeemed[contributorAddress] = true;
        isOriginalOrRedeemedContributor[redeemAddress] = true;

        // Once the contributorAddress has moved the funds to the new RSK address, what to do with the old address?
        // Users should not receive RIFs in the old address from other users. If they do, they may not be able to access
        // those RIFs.
        return transferAll(contributorAddress, redeemAddress);
    }

    function getRedirectedAddress(address a) public view returns(address) {
        address r = redirect[a];

        if (r != ZERO_ADDRESS) {
            return r;
        }

        return a;
    }

    function validAddress(address a) public pure returns(bool) {
        return (a != ZERO_ADDRESS);
    }

    function wasRedirected(address a) public view returns(bool) {
        return (redirect[a] != ZERO_ADDRESS);
    }

    function transfer(address _to, uint256 _value) public onlyAfterDistribution onlyIfAddressUsable(msg.sender) returns (bool) {
        // cannot transfer to a redirected account
        if (wasRedirected(_to)) return false;

        bool result = super.transfer(_to, _value);

        if (!result) return false;

        doTrackMinimums(msg.sender);

        return true;
    }

    /**
     * ERC-677's only method implementation
     * See https://github.com/ethereum/EIPs/issues/677 for details
     */
    function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
        bool result = transfer(_to, _value);
        if (!result) return false;

        emit Transfer(msg.sender, _to, _value, _data);

        ERC677TransferReceiver receiver = ERC677TransferReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);

        // IMPORTANT: the ERC-677 specification does not say
        // anything about the use of the receiver contract's
        // tokenFallback method return value. Given
        // its return type matches with this method's return
        // type, returning it could be a possibility.
        // We here take the more conservative approach and
        // ignore the return value, returning true
        // to signal a succesful transfer despite tokenFallback's
        // return value -- fact being tokens are transferred
        // in any case.
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public onlyAfterDistribution onlyIfAddressUsable(_from) returns (bool) {
        // cannot transfer to a redirected account
        if (wasRedirected(_to)) return false;

        bool result = super.transferFrom(_from, _to, _value);
        if (!result) return false;

        doTrackMinimums(_from);

        return true;
    }

    function approve(address _spender, uint256 _value) public onlyAfterDistribution onlyIfAddressUsable(msg.sender) returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public onlyAfterDistribution onlyIfAddressUsable(msg.sender) returns (bool) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public onlyAfterDistribution onlyIfAddressUsable(msg.sender) returns (bool) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function doTrackMinimums(address addr) private {
        // We only track minimums while there's a manager
        // contract that can pay the bonuses for which
        // these minimums are tracked for in the first place.
        if (!enableManagerContract) return;

        uint m = minimumLeftFromSale[addr];

        if ((m>0) && (balances[addr] < m)) {
            minimumLeftFromSale[addr] = balances[addr];
        }
    }
}
