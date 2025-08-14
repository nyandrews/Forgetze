import Foundation
import SwiftData

@Model
final class Birthday: Identifiable, Validatable {
    var month: Int
    var day: Int
    var year: Int?
    var id: String
    
    init(month: Int, day: Int, year: Int? = nil) {
        self.month = month
        self.day = day
        self.year = year
        self.id = "\(month)-\(day)-\(year ?? 0)"
    }
    
    convenience init(date: Date) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        self.init(month: month, day: day, year: year)
    }
    
    var date: Date {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.year = year ?? 2000 // Default year for age calculation
        
        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }
    
    var age: Int? {
        guard let year = year else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let birthdayThisYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: month, day: day)) ?? Date()
        
        var age = calendar.component(.year, from: now) - year
        
        // Adjust age if birthday hasn't occurred yet this year
        if now < birthdayThisYear {
            age -= 1
        }
        
        return age
    }
    
    var displayString: String {
        let monthName = Calendar.current.monthSymbols[month - 1]
        if let year = year {
            return "\(monthName) \(day), \(year)"
        } else {
            return "\(monthName) \(day)"
        }
    }
    
    var shortDisplayString: String {
        let monthName = Calendar.current.shortMonthSymbols[month - 1]
        if let year = year {
            return "\(monthName) \(day), \(year)"
        } else {
            return "\(monthName) \(day)"
        }
    }
    
    var monthName: String {
        Calendar.current.monthSymbols[month - 1]
    }
    
    var shortMonthName: String {
        Calendar.current.shortMonthSymbols[month - 1]
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        month >= 1 && month <= 12 && day >= 1 && day <= 31
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if month < 1 || month > 12 {
            errors.append("Month must be between 1 and 12")
        }
        
        if day < 1 || day > 31 {
            errors.append("Day must be between 1 and 31")
        }
        
        // Additional validation for specific months
        if month == 2 && day > 29 {
            errors.append("February cannot have more than 29 days")
        } else if [4, 6, 9, 11].contains(month) && day > 30 {
            errors.append("This month cannot have more than 30 days")
        }
        
        return errors
    }
}
