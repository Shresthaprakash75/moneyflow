import SwiftUI

struct Expense: Identifiable, Codable {
    var id = UUID()
    let amount: Double
    let description: String
    let category: String
}

struct AddExpensesView: View {
    @State private var expenses: [Expense] = []
    @State private var expenseAmount: String = ""
    @State private var expenseDescription: String = ""
    @State private var selectedCategory: String = ""
    @State private var categories: [String] = ["Food", "Socializing", "Transport", "Shopping", "Other"]
    @State private var isAddingNewCategory: Bool = false
    @State private var newCategoryName: String = ""
    @State private var isAmountValid: Bool = true

    var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            VStack {
                totalExpenseView

                Form {
                    addExpenseSection
                }

                expenseList
            }
            .navigationTitle("Expense Tracker")
            .onAppear(perform: loadExpenses)
        }
    }
}

// MARK: - Subviews
private extension AddExpensesView {
    var totalExpenseView: some View {
        HStack {
            Text("Total Expenses:")
                .font(.headline)
            Spacer()
            Text("$\(totalExpense, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
    }

    var addExpenseSection: some View {
        Section(header: Text("Add Expense")) {
            CustomTextField(
                placeholder: "Amount (e.g., 50.75)",
                text: $expenseAmount,
                keyboardType: .decimalPad,
                borderColor: isAmountValid ? .gray : .red
            )
            .onChange(of: expenseAmount) { newValue in
                validateAmount()
            }

            CustomTextField(placeholder: "Description (e.g., Lunch)", text: $expenseDescription)

            CategoryPicker(
                categories: categories,
                selectedCategory: $selectedCategory,
                isAddingNewCategory: $isAddingNewCategory
            )

            if isAddingNewCategory {
                addNewCategoryView
                    .transition(.opacity.combined(with: .slide))
            }

            Button(action: addExpense) {
                Text("Add Expense")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!isFormValid)
        }
    }

    var addNewCategoryView: some View {
        VStack(alignment: .leading) {
            CustomTextField(placeholder: "New Category Name", text: $newCategoryName, borderColor: .blue)

            HStack {
                Button("Cancel") {
                    cancelNewCategory()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Add") {
                    addNewCategory()
                }
                .disabled(newCategoryName.isEmpty)
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical)
    }

    var expenseList: some View {
        List {
            Section(header: Text("Expenses")) {
                if expenses.isEmpty {
                    Text("No expenses added yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(expenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.description)
                                    .font(.headline)
                                Text(expense.category)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("$\(expense.amount, specifier: "%.2f")")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Helper Functions
private extension AddExpensesView {
    var isFormValid: Bool {
        !expenseAmount.isEmpty &&
        !expenseDescription.isEmpty &&
        !selectedCategory.isEmpty &&
        isAmountValid
    }

    func validateAmount() {
        isAmountValid = Double(expenseAmount) != nil
    }

    func addExpense() {
        if let amount = Double(expenseAmount) {
            let newExpense = Expense(amount: amount, description: expenseDescription, category: selectedCategory)
            expenses.append(newExpense)
            saveExpenses()
            clearExpenseForm()
        }
    }

    func addNewCategory() {
        if !newCategoryName.isEmpty {
            categories.append(newCategoryName)
            selectedCategory = newCategoryName
            cancelNewCategory()
        }
    }

    func cancelNewCategory() {
        withAnimation {
            newCategoryName = ""
            isAddingNewCategory = false
        }
    }

    func clearExpenseForm() {
        expenseAmount = ""
        expenseDescription = ""
        selectedCategory = ""
    }

    func saveExpenses() {
        if let encodedData = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encodedData, forKey: "expenses")
        }
    }

    func loadExpenses() {
        if let savedData = UserDefaults.standard.data(forKey: "expenses"),
           let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: savedData) {
            expenses = decodedExpenses
        }
    }
}

// MARK: - Custom Components
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var borderColor: Color = .gray

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

struct CategoryPicker: View {
    let categories: [String]
    @Binding var selectedCategory: String
    @Binding var isAddingNewCategory: Bool

    var body: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(categories, id: \.self) { category in
                Text(category)
            }
            Text("Add New Category").tag("Add New Category")
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: selectedCategory) { oldValue, newValue in
            if newValue == "Add New Category" {
                withAnimation {
                    isAddingNewCategory = true
                    selectedCategory = ""
                }
            }
        }
    }
}

struct AddExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpensesView()
    }
}
