# MurtaaxPay App

MurtaaxPay is a premium Fintech application designed for the Somali Diaspora, focusing on secure transactions, community savings (Hagbad), and a responsive UI.

## Key Features

- **Wallet Management**: Securely manage your balance, send and receive money.
- **Hagbad (Community Savings)**: 
  - **Qori-tuur (Lottery)**: Randomized payout order.
  - **Dhaar (Religious Oath)**: Social trust mechanism for commitments.
  - **Uul (Guarantor)**: regional regional logic for specific prefixes (252/256) to ensure repayment.
- **Withdrawals**: Flexible withdrawal options to Mobile Money (EVC Plus, e-Dahab, ZAAD, Sahal) and local banks (IBS, Premier, Amal).
- **Responsive Design**: Optimized for Mobile, Tablet, and Desktop using `ResponsiveFramework`.
- **Localization**: Full support for Somali and English languages.
- **Security**: PIN-based authorization for all sensitive transactions.

## Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **UI Enhancement**: Animate-do, Responsive Framework, Google Fonts
- **Local Storage**: Shared Preferences

## Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/murtaapay-app.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

## Business Logic Notes

- **Withdrawal Fee**: 1% fee (minimum $0.10) applied to withdrawals between $1 and $2000.
- **Regional Logic**: Specific features like "Uul" (Guarantor) are triggered based on user regional prefixes (+252 for Somalia, +256 for Uganda).
- **Simulated Failures**: PIN '0000' or amount 666.0 triggers simulated transaction failures for testing purposes.
