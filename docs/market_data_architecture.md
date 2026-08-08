# Centralized Market Data Architecture

This document outlines the architecture for real-time market data integration (FX rates, Gold, and Silver prices) within the MurtaaxPay application.

## 1. Overview

The system is designed to provide globally consistent conversion rates and Zakat Nisab thresholds across all features. It ensures that users always see the most accurate financial data, whether they are sending money, calculating Zakat, or managing their savings.

## 2. Key Components

### 2.1 Single Source of Truth (`AppState`)
The `AppState` class (`lib/core/app_state.dart`) serves as the central hub for all market data.
- **State Variables**: Holds `_fxRates` (Map), `_goldPrice` (USD/g), and `_silverPrice` (USD/g).
- **Core Logic**:
    - `getExchangeRate(from, to)`: Calculates cross-currency rates through a USD base.
    - `convertAmount(amount, from, to)`: Performs the actual conversion, applying specific precision rules (e.g., 4 decimals for SOS).
    - `updateNisabValues()`: Dynamically calculates Zakat thresholds based on 87.48g of gold and 612.36g of silver using current prices.
- **Notification**: Calls `notifyListeners()` whenever rates are updated to trigger UI refreshes.

### 2.2 Data Fetching Layer (`ApiService`)
The `ApiService` (`lib/core/api_service.dart`) handles external communication.
- **`fetchAllRates()`**: Fetches the latest rates from the backend API.
- **Fallbacks**: Includes a robust set of default market rates to ensure the app remains functional even in offline mode or during API downtime.

### 2.3 Lifecycle Management (`MurtaaxPayApp`)
To ensure data freshness, the app automatically refreshes market rates during its lifecycle.
- **`WidgetsBindingObserver`**: Implemented in `main.dart` within the root `MurtaaxPayApp` state.
- **Auto-Refresh**: Triggers `AppState.updateMarketRates()` whenever the `AppLifecycleState` changes to `resumed` (app coming to foreground).

## 3. Data Flow Diagram

```text
[ External API ] <--- [ ApiService.fetchAllRates() ]
                            |
                            v
[ AppState ] <--- ( Stores Rates & Commodity Prices )
    |
    |--- [ Logic: convertAmount, getExchangeRate ]
    |--- [ Logic: updateNisabValues ]
    |
    +-----> [ UI: SendAmountScreen ] (FX Conversion & Fees)
    +-----> [ UI: ZakatCalculatorScreen ] (Nisab Thresholds)
    +-----> [ UI: SavingsScreen ] (Valuation)
```

## 4. Precision and Rounding

- **Standard**: Most currencies use 2-decimal precision for displays.
- **High Nominal (SOS)**: Somali Shilling (SOS) and other high-nominal currencies utilize 4-decimal precision for exchange rates within conversion logic to prevent significant rounding errors during large transfers.

## 5. Zakat Nisab Calculation

Nisab values are not hardcoded. They are calculated as follows:
- **Gold Nisab**: `Current Gold Price per gram * 87.48`
- **Silver Nisab**: `Current Silver Price per gram * 612.36`

Users can toggle their preferred Nisab base (Gold vs Silver) in the `ZakatCalculatorScreen`, which updates the `AppState` and reflects across the UI instantly.
