
# Aidrex - Beneficiary Donation and Fund Utilization Smart Contract (Clarity)

## Overview

This Clarity smart contract implements a **donation and fund utilization system** with **role-based access control** on the Stacks blockchain. It allows users to:

* Register beneficiaries
* Donate to verified causes
* Track fund utilization by milestones
* Authorize usage of funds by administrators

The system ensures transparency, traceability, and accountability for donations and their use.

---

## 🎯 Features

### ✅ Role-Based Access Control

* **Owner**: Deployer of the contract; has full control.
* **Admin**: Can manage fund utilization, approve spending.
* **Moderator**: Can register beneficiaries.
* **Beneficiary**: Target recipient of donations (read-only permissions).

### 📋 Beneficiary Management

* `register-beneficiary`: Register a new beneficiary (only for Moderators).
* `get-beneficiary`: Fetch a beneficiary's full details by ID.

### 💸 Donations

* `donate`: Donate a specified amount to a beneficiary.
* `get-donation-by-id`: View donation details by ID.
* `get-donation-count`: Get the total number of donations recorded.

### 📊 Utilization Tracking

* `add-utilization`: Add a fund utilization milestone (Admins only).
* `approve-utilization`: Approve spending for a milestone.
* `get-utilization-by-id`: Get details of a specific milestone.
* `get-utilization-count`: Get total utilization entries.

### 🔐 Role Management

* `set-role`: Assign a role to a user (Owner only).
* `remove-role`: Remove a user's role (Owner only).

---

## 🛡️ Validation & Error Handling

The contract uses several error constants to manage state and access violations:

* `ERR-NOT-AUTHORIZED (u100)`
* `ERR-ALREADY-REGISTERED (u101)`
* `ERR-NOT-FOUND (u102)`
* `ERR-INSUFFICIENT-FUNDS (u103)`
* `ERR-BENEFICIARY-NOT-FOUND (u104)`
* `ERR-UTILIZATION-NOT-FOUND (u105)`
* `ERR-INVALID-INPUT (u106)`

---

## 🏗️ Data Models

### `roles` (Map)

* **Key**: `user` (principal)
* **Value**: `role` (uint)

### `beneficiaries` (Map)

* **Key**: `id` (uint)
* **Values**:

  * `name`, `description`
  * `target-amount`, `received-amount`
  * `status`

### `donations` (Map)

* **Key**: `id` (uint)
* **Values**:

  * `donor`, `beneficiary-id`
  * `amount`, `timestamp`

### `utilization` (Map)

* **Key**: `id` (uint)
* **Values**:

  * `beneficiary-id`, `milestone`
  * `description`, `amount`, `status`

---

## 🏁 Initialization

On deployment, the contract:

* Sets the deployer as `contract-owner`
* Assigns the deployer the `ROLE-ADMIN`

---

## 🔐 Access Control Summary

| Function                  | Role Required     |
| ------------------------- | ----------------- |
| `register-beneficiary`    | Moderator         |
| `add-utilization`         | Admin             |
| `approve-utilization`     | Admin             |
| `set-role`, `remove-role` | Owner (deployer)  |
| `donate`, `get-*`         | Public (any user) |

---

## 🔧 How to Deploy

1. Deploy the contract to a Stacks testnet or mainnet using a Clarity-enabled tool like [Clarinet](https://docs.stacks.co/docs/clarity/clarinet).
2. After deployment, the deployer will have `ROLE-ADMIN` privileges.
3. Use `set-role` to assign roles to other users.

---
