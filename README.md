# Money Metriz App

This is an Money Metriz app built using Flutter and integrated with the appWrite SDK for transaction tracking and analytics. The app allows users to track their expenses, view transaction details, and analyze their spending patterns. This Read Me document provides instructions on how to clone the project and set it up for development or testing purposes.

## App Flow
![Arch](https://github.com/Iamprashanth-1/Money-Metriz/blob/master/assets/images/app-arch.png)

## Prerequisites

Before cloning and running this project, make sure you have the following installed on your development machine:

- Flutter SDK: version 2.0.0 or higher
- Dart: version 2.12.0 or higher
- Git: version 2.0 or higher

## Installation

Follow these steps to clone and set up the project:

1. Open a terminal or command prompt.

2. Clone the project repository by running the following command:

   ```shell
   git clone https://github.com/Iamprashanth-1/Money-Metriz.git
   ```


3. Navigate to the project directory:

   ```shell
   cd money_metriz
   ```

4. Install the project dependencies by running the following command:

   ```shell
   flutter pub get
   ```

5. Set up the appWrite SDK:

   - Sign up for an account on the appWrite website (https://appWrite.io) if you haven't already.
   - Create a new project and obtain the SDK key.
   - Open the file `lib/appWrite/appWrite_service.dart` and replace the placeholder value for `sdkKey` with your obtained SDK key.

6. Run the app on a simulator or connected device:

   ```shell
   flutter run
   ```

   This command will build the app and launch it on the selected device.


## Features
The Money Metriz app has the following features:

- Add and manage transactions
- View transaction history
- View transaction analytics
- Filter transactions by date range

## Usage

Once the app is running, you can perform the following actions:

- Add expenses: Click on the "Add Expense" button to enter details such as amount, category, and description for a new expense. Save the expense to track it.
- View transactions: The app displays a list of transactions, including the date, amount, category, and description. Scroll through the list to see all your recorded expenses.
- Analyze spending patterns: Access the analytics section to view visual representations of your spending patterns. The app provides charts and graphs to help you understand your expenses better.

## Contributing

Contributions to this project are welcome. If you find any issues or have suggestions for improvement, feel free to open an issue or submit a pull request on the project repository.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the code according to the terms of this license.

## Contact

If you have any questions or need further assistance, you can reach out to the project maintainer at [mprashanth059@gmail.com](mailto:mprashanth059@gmail.com).

LinkedIn : https://www.linkedin.com/in/iam-prashanth/

---

Thank you for your interest in the Money Metriz app! Happy tracking and managing your expenses!