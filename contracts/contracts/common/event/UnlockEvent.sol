// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

library UnlockEvent {
    event Unlocked (
        uint128 amount,
        address recipient
    );
}