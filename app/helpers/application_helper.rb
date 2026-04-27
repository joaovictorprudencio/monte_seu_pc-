module ApplicationHelper
    def format_currency(amount)
      number_to_currency(amount, unit: "R$", separator: ",", delimiter: ".", precision:2)
    end
end
