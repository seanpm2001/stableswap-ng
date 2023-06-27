# @version ^0.3.7

"""
@notice Rebase ERC20 mock with pseudo-randomly rebase by 1% on every transfer
@dev This is for testing only, it is NOT safe for use
@dev Based on stEth implementation
"""


event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    _value: uint256


event TransferShares:
    _from: indexed(address)
    _to: indexed(address)
    _value: uint256


event Approval:
    _owner: indexed(address)
    _spender: indexed(address)
    _value: uint256


name: public(String[64])
symbol: public(String[32])
decimals: public(uint256)
allowances: HashMap[address, HashMap[address, uint256]]

# <--- Rebase Parameters --->
totalCoin: public(uint256)
totalShares: public(uint256)
shares: public(HashMap[address, uint256])
IS_UP: immutable(bool)


@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint256, is_up: bool):
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    IS_UP = is_up


@external
@view
def totalSupply() -> uint256:
    # Rebase is pegged to total pooled coin
    return self.totalCoin


@external
@view
def balanceOf(_user: address) -> uint256:
    return self._get_coins_by_shares(self.shares[_user])


@external
@view
def allowance(_owner: address, _spender: address) -> uint256:
    return self.allowances[_owner][_spender]


@external
def transfer(_to: address, _value: uint256) -> bool:
    self._rebase()
    _shares: uint256 = self._get_shares_by_coins(_value)

    self.shares[msg.sender] -= _shares
    self.shares[_to] += _shares
    log Transfer(msg.sender, _to, _value)
    log TransferShares(msg.sender, _to, _shares)
    return True


@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    self._rebase()
    _shares: uint256 = self._get_shares_by_coins(_value)

    self.shares[_from] -= _shares
    self.shares[_to] += _shares
    self.allowances[_from][msg.sender] -= _value

    log Transfer(_from, _to, _value)
    log TransferShares(_from, _to, _shares)
    return True


@external
def approve(_spender: address, _value: uint256) -> bool:
    self.allowances[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True


@internal
@view
def _share_price() -> uint256:
    if self.totalShares == 0:
        return 10 ** self.decimals
    return self.totalCoin * 10 ** self.decimals / self.totalShares


@internal
@view
def _get_coins_by_shares(_shares: uint256) -> uint256:
    return _shares * self._share_price() / 10 ** self.decimals


@internal
@view
def _get_shares_by_coins(_coins: uint256) -> uint256:
    return _coins * 10 ** self.decimals / self._share_price()


@external
@view
def share_price() -> uint256:
    return self._share_price()


@internal
def _rebase():
    if IS_UP:
        self.totalCoin = self.totalCoin * 101 / 100
    else:
        self.totalCoin = self.totalCoin * 99 / 100


@external
def set_total_coin(total_coin: uint256) -> bool:
    assert self.totalShares != 0, "no shares"

    self.totalCoin = total_coin
    return True
