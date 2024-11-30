import SwiftUI

// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    var id = UUID()
    let amount: Double
    let description: String
    let category: String
}

// MARK: - AddExpensesView
struct AddExpensesView: View {
    @State private var expenses: [Expense] = []
    @State private var expenseAmount: String = ""
    @State private var expenseDescription: String = ""
    @State private var selectedCategory: String = ""
    @State private var categories: [String] = ["Food", "Socializing", "Transport", "Shopping", "Other"]
    @State private var isAmountValid: Bool = true
    @State private var isManagingCategories: Bool = false

    private var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            VStack {
                totalExpenseView
                Form { addExpenseSection }
                expenseList
            }
            .navigationTitle("Expense Tracker")
            .onAppear(perform: loadExpenses)
            .sheet(isPresented: $isManagingCategories) {
                ManageCategoriesView(categories: $categories)
            }
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
                .foregroundColor(.red)
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
            .onChange(of: expenseAmount) { oldState, newState in validateAmount() }

            CustomTextField(placeholder: "Description (e.g., Lunch)", text: $expenseDescription)

            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { Text($0) }
                Text("Manage Categories").tag("Manage Categories")
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedCategory) { _, newValue in
                if newValue == "Manage Categories" {
                    selectedCategory = ""
                    isManagingCategories = true
                }
            }

            Button(action: addExpense) {
                Text("Add Expense")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!isFormValid)
        }
    }

    var expenseList: some View {
        List {
            Section(header: Text("Expenses")) {
                if expenses.isEmpty {
                    Text("No expenses added yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
        }
    }
}

// MARK: - Components
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

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.description).font(.headline)
                Text(expense.category).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Text("$\(expense.amount, specifier: "%.2f")").foregroundColor(.gray)
        }
    }
}

// MARK: - ManageCategoriesView
struct ManageCategoriesView: View {
    @Binding var categories: [String]
    @Environment(\.presentationMode) var presentationMode
    @State private var newCategoryName: String = ""
    @State private var editingCategoryIndex: Int? = nil

    var body: some View {
        NavigationView {
            VStack {
                categoryList
                newCategoryField
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }

    private var categoryList: some View {
        List {
            ForEach(categories.indices, id: \.self) { index in
                HStack {
                    if editingCategoryIndex == index {
                        TextField("Edit Category", text: Binding(
                            get: { categories[index] },
                            set: { categories[index] = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(categories[index])
                    }
                    Spacer()
                    Button(action: { toggleEditing(index: index) }) {
                        Image(systemName: editingCategoryIndex == index ? "checkmark" : "pencil")
                    }
                }
            }
            .onDelete(perform: deleteCategory)
        }
    }

    private var newCategoryField: some View {
        HStack {
            TextField("New Category", text: $newCategoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Add", action: addCategory)
                .disabled(newCategoryName.isEmpty)
                .padding(.horizontal)
                .foregroundColor(.blue)
        }
        .padding()
    }

    private func toggleEditing(index: Int) {
        editingCategoryIndex = editingCategoryIndex == index ? nil : index
    }

    private func addCategory() {
        if !newCategoryName.isEmpty {
            categories.append(newCategoryName)
            newCategoryName = ""
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }
}

// MARK: - CustomTextField
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

// MARK: - Preview
struct AddExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpensesView()
    }
}
