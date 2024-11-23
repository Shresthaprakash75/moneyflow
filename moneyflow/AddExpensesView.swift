import SwiftUI

struct Expense: Identifiable {
    let id = UUID()
    let amount: Double
    let description: String
}

struct AddExpensesView: View {
    @State private var expenses: [Expense] = []
    @State private var expenseAmount: String = ""
    @State private var expenseDescription: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add Expense")) {
                        TextField("Amount (e.g., 50.75)", text: $expenseAmount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        TextField("Description (e.g., Lunch)", text: $expenseDescription)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        Button(action: addExpense) {
                            Text("Add Expense")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(expenseAmount.isEmpty || expenseDescription.isEmpty)
                    }
                }
                .padding(.bottom)
                
                List {
                    Section(header: Text("Expenses")) {
                        ForEach(expenses) { expense in
                            HStack {
                                Text(expense.description)
                                    .font(.headline)
                                Spacer()
                                Text("$\(expense.amount, specifier: "%.2f")")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Expense Tracker")
        }
    }
    
    private func addExpense() {
        if let amount = Double(expenseAmount) {
            let newExpense = Expense(amount: amount, description: expenseDescription)
            expenses.append(newExpense)
            expenseAmount = ""
            expenseDescription = ""
        }
    }
}

struct AddExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpensesView()
    }
}
