// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";

import {RumpelGuard} from "../src/RumpelGuard.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {Enum} from "../src/interfaces/external/ISafe.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract ApplyJsonConfig is Script {
    using stdJson for string;

    struct GuardProtocolAllow {
        address target;
        string name; // optional: resolve via address book
        string[] selectors; // Function signatures e.g. "deposit(uint256,address)" or short names e.g. "deposit"
        string state; // "OFF" | "ON" | "PERMANENTLY_ON"
    }

    struct GuardTokenAllow {
        address token;
        string name; // optional: resolve via address book
        string transfer; // "OFF" | "ON" | "PERMANENTLY_ON"
        string approve; // "OFF" | "ON" | "PERMANENTLY_ON"
    }

    struct ModuleProtocolBlock {
        address target;
        string name; // optional: resolve via address book
        string[] blockedSelectors; // Function signatures e.g. "redeem(uint256,address,address)" or short names e.g. "redeem"
    }

    struct ModuleTokenBlock {
        address token;
        string name; // optional: resolve via address book
        bool blockTransfer;
        bool blockApprove;
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address guardAddr = vm.envAddress("RUMPEL_GUARD");
        address moduleAddr = vm.envAddress("RUMPEL_MODULE");
        string memory jsonPath = vm.envString("CONFIG_JSON");

        vm.startBroadcast(deployerPrivateKey);
        applyAll(RumpelGuard(guardAddr), RumpelModule(moduleAddr), jsonPath);
        vm.stopBroadcast();
    }

    function applyAll(RumpelGuard guard, RumpelModule module, string memory jsonPath) public {
        string memory json = vm.readFile(jsonPath);
        string memory book = _getAddressBookOrEmpty();
        _applyGuardJson(guard, json, book);
        _applyModuleJson(module, json, book);
    }

    function _applyGuardJson(RumpelGuard guard, string memory json, string memory book) internal {
        // Protocol allows (index-based scan until parse fails)
        for (uint256 i = 0;; i++) {
            string memory base = string.concat(".guard.protocols[", _toString(i), "]");
            (bool okTarget, address target) = _tryReadAddress(json, string.concat(base, ".target"));
            (bool okName, string memory name) = _tryReadString(json, string.concat(base, ".name"));
            if (!okTarget && !okName) break;

            (, string memory stateStr) = _tryReadString(json, string.concat(base, ".state"));
            RumpelGuard.AllowListState state = _parseState(stateStr);
            string[] memory selectors = _readStringArray(json, string.concat(base, ".selectors"));

            address resolved = _resolveTarget(target, name, book);
            for (uint256 j = 0; j < selectors.length; j++) {
                bytes4 selector = _parseSelector(selectors[j]);
                try guard.setCallAllowed(resolved, selector, state) {} catch {}
            }
        }

        // Token allows
        for (uint256 i = 0;; i++) {
            string memory base = string.concat(".guard.tokens[", _toString(i), "]");
            (bool okToken, address tokenAddr) = _tryReadAddress(json, string.concat(base, ".token"));
            (bool okName2, string memory tokenName) = _tryReadString(json, string.concat(base, ".name"));
            if (!okToken && !okName2) break;

            (, string memory transferStr) = _tryReadString(json, string.concat(base, ".transfer"));
            (, string memory approveStr) = _tryReadString(json, string.concat(base, ".approve"));
            RumpelGuard.AllowListState transferState = _parseState(transferStr);
            RumpelGuard.AllowListState approveState = _parseState(approveStr);

            address resolvedToken = _resolveTarget(tokenAddr, tokenName, book);
            try guard.setCallAllowed(resolvedToken, _selectorTransfer(), transferState) {} catch {}
            try guard.setCallAllowed(resolvedToken, _selectorApprove(), approveState) {} catch {}
        }
    }

    function _applyModuleJson(RumpelModule module, string memory json, string memory book) internal {
        // Protocol blocks
        for (uint256 i = 0;; i++) {
            string memory base = string.concat(".module.protocols[", _toString(i), "]");
            (bool okTarget, address target) = _tryReadAddress(json, string.concat(base, ".target"));
            (bool okName, string memory name) = _tryReadString(json, string.concat(base, ".name"));
            if (!okTarget && !okName) break;

            address resolved = _resolveTarget(target, name, book);
            string[] memory blocked = _readStringArray(json, string.concat(base, ".blockedSelectors"));
            for (uint256 j = 0; j < blocked.length; j++) {
                bytes4 selector = _parseSelector(blocked[j]);
                module.addBlockedModuleCall(resolved, selector);
            }
        }

        // Token blocks
        for (uint256 i = 0;; i++) {
            string memory base = string.concat(".module.tokens[", _toString(i), "]");
            (bool okToken, address tokenAddr) = _tryReadAddress(json, string.concat(base, ".token"));
            (bool okName2, string memory tokenName) = _tryReadString(json, string.concat(base, ".name"));
            if (!okToken && !okName2) break;

            address resolved = _resolveTarget(tokenAddr, tokenName, book);
            (bool okBT, bool blockTransfer) = _tryReadBool(json, string.concat(base, ".blockTransfer"));
            (bool okBA, bool blockApprove) = _tryReadBool(json, string.concat(base, ".blockApprove"));
            if (okBT && blockTransfer) module.addBlockedModuleCall(resolved, _selectorTransfer());
            if (okBA && blockApprove) module.addBlockedModuleCall(resolved, _selectorApprove());
        }
    }

    function _tryReadAddress(string memory json, string memory path) internal view returns (bool, address) {
        try vm.parseJsonAddress(json, path) returns (address a) {
            return (true, a);
        } catch {
            return (false, address(0));
        }
    }

    function _tryReadString(string memory json, string memory path) internal view returns (bool, string memory) {
        try vm.parseJsonString(json, path) returns (string memory s) {
            return (true, s);
        } catch {
            return (false, "");
        }
    }

    function _tryReadBool(string memory json, string memory path) internal view returns (bool, bool) {
        try vm.parseJson(json, path) returns (bytes memory raw) {
            return (true, abi.decode(raw, (bool)));
        } catch {
            return (false, false);
        }
    }

    function _readStringArray(string memory json, string memory path) internal view returns (string[] memory arr) {
        try vm.parseJson(json, path) returns (bytes memory raw) {
            arr = abi.decode(raw, (string[]));
        } catch {
            arr = new string[](0);
        }
    }

    function _parseState(string memory s) internal pure returns (RumpelGuard.AllowListState) {
        bytes32 h = keccak256(bytes(_uppercase(s)));
        if (h == keccak256("OFF")) return RumpelGuard.AllowListState.OFF;
        if (h == keccak256("ON")) return RumpelGuard.AllowListState.ON;
        if (h == keccak256("PERMANENTLY_ON")) return RumpelGuard.AllowListState.PERMANENTLY_ON;
        revert("Unknown state");
    }

    function _parseSelector(string memory sigOrName) internal pure returns (bytes4) {
        bytes memory b = bytes(sigOrName);
        bool hasParen = false;
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == bytes1("(")) {
                hasParen = true;
                break;
            }
        }
        if (hasParen) {
            return bytes4(keccak256(bytes(sigOrName)));
        }
        bytes32 h = keccak256(bytes(_lowercase(sigOrName)));
        if (h == keccak256("deposit")) return _selectorDeposit();
        if (h == keccak256("redeem")) return _selectorRedeem();
        if (h == keccak256("withdraw")) return _selectorWithdraw();
        if (h == keccak256("approve")) return _selectorApprove();
        if (h == keccak256("transfer")) return _selectorTransfer();
        revert("Unknown selector name");
    }

    function _selectorDeposit() internal pure returns (bytes4) {
        return bytes4(keccak256("deposit(uint256,address)"));
    }

    function _selectorRedeem() internal pure returns (bytes4) {
        return bytes4(keccak256("redeem(uint256,address,address)"));
    }

    function _selectorWithdraw() internal pure returns (bytes4) {
        return bytes4(keccak256("withdraw(uint256,address,address)"));
    }

    function _selectorApprove() internal pure returns (bytes4) {
        return bytes4(keccak256("approve(address,uint256)"));
    }

    function _selectorTransfer() internal pure returns (bytes4) {
        return bytes4(keccak256("transfer(address,uint256)"));
    }

    function dryRunDeployAndApply(string memory jsonPath) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        RumpelGuard guard = new RumpelGuard(address(0));
        RumpelModule module = new RumpelModule(address(0));
        applyAll(guard, module, jsonPath);
        vm.stopBroadcast();
        console.log("Dry-run deployed Guard:", address(guard));
        console.log("Dry-run deployed Module:", address(module));
    }

    function _resolveTarget(address direct, string memory name, string memory book) internal view returns (address) {
        if (direct != address(0)) return direct;
        bytes memory nb = bytes(name);
        if (nb.length == 0) revert("No target or name provided");
        if (bytes(book).length == 0) revert("ADDRESS_BOOK_JSON not set");
        string memory path = string.concat(".", _toString(block.chainid), ".", name);
        return book.readAddress(path);
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function _getAddressBookOrEmpty() internal view returns (string memory) {
        try vm.envString("ADDRESS_BOOK_JSON") returns (string memory p) {
            if (bytes(p).length == 0) return "";
            return vm.readFile(p);
        } catch {
            return "";
        }
    }

    function _uppercase(string memory s) internal pure returns (string memory) {
        bytes memory b = bytes(s);
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 97 && c <= 122) {
                b[i] = bytes1(c - 32);
            }
        }
        return string(b);
    }

    function _lowercase(string memory s) internal pure returns (string memory) {
        bytes memory b = bytes(s);
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 65 && c <= 90) {
                b[i] = bytes1(c + 32);
            }
        }
        return string(b);
    }
}
